#' @title Sort dNdS Values Into Divergence Strata
#' @description This function takes a data.table returned by dNdS
#' and sorts the corresponding dNdS value into divergence strata (deciles).
#' @param dNdS_tbl a data.table object returned by \code{\link{dNdS}}.
#' @param subject.id a logical value indicating whether \code{query_id} AND \code{subject_id} should be returned.
#' @details 
#' 
#' Divergence Strata are decile values of corresponding \code{\link{dNdS}} values.
#' The \code{\link{dNdS}} function returns dNdS values for orthologous genes
#' of a query species (versus subject species). These dNdS values are then
#' sorted into deciles and each orthologous protein coding gene of the
#' query species receives a corresponding decile value instead of the initial dNdS value.
#' 
#' This allows a better comparison between Phylostrata and Divergence Strata (for more details see package: \pkg{myTAI}).
#' 
#' 
#' @author Hajk-Georg Drost
#' @examples \dontrun{
#' 
#' # get a divergence map of example sequences
#' dNdS_tbl <- dNdS( 
#'               query_file      = system.file('seqs/ortho_thal_cds.fasta', package = 'orthologr'),
#'               subject_file    = system.file('seqs/ortho_lyra_cds.fasta', package = 'orthologr'),
#'               ortho_detection = "RBH", 
#'               aa_aln_type     = "pairwise",
#'               aa_aln_tool     = "NW", 
#'               codon_aln_tool  = "pal2nal", 
#'               dnds_est.method = "Comeron", 
#'               comp_cores      = 1 )
#'                  
#' divMap <- divergence_map( dNdS_tbl )                       
#' 
#' # in case you want the subject_id as well, you can set
#' # the argument subject.id = TRUE
#' divMap <- divergence_map( dNdS_tbl = dNdS_tbl, subject.id = TRUE)               
#' 
#' }
#' @seealso \code{\link{divergence_stratigraphy}}
#' @return a data.table storing a standard divergence map.
#' @import data.table
#' @export

divergence_map <- function(dNdS_tbl, subject.id = FALSE){
        
        # due to the discussion of no visible binding for global variable for
        # data.table objects see:
        # http://stackoverflow.com/questions/8096313/no-visible-binding-for-global-variable-note-in-r-cmd-check?lq=1
        query_id <- subject_id <- divergence_strata <- NULL
        
        data.table::setDT(dNdS_tbl)
        data.table::setkeyv(dNdS_tbl, c("query_id","subject_id"))
        
        dNdS_tbl_divMap <-
                data.table::as.data.table(dplyr::select(dtplyr::lazy_dt(dNdS_tbl), dNdS, query_id, subject_id))
        
        DecileValues <-
                stats::quantile(dNdS_tbl_divMap[ , dNdS],
                                probs = seq(0.0, 1, 0.1),
                                na.rm = TRUE)
        
        for (i in length(DecileValues):2) {
                AllGenesOfDecile_i <-
                        stats::na.omit(which((dNdS_tbl_divMap[ , dNdS] < DecileValues[i]) &
                                                     (dNdS_tbl_divMap[ , dNdS] >= DecileValues[i - 1])
                        ))
                dNdS_tbl_divMap[AllGenesOfDecile_i, dNdS := (i - 1)]
                
        }
        
        ## assigning all KaKs values to Decile-Class : 10 which have the exact Kaks-value
        ## as the 100% quantile, because in the loop we tested for < X% leaving out
        ## the exact 100% quantile
        dNdS_tbl_divMap[which(dNdS_tbl_divMap[ , dNdS] == DecileValues[length(DecileValues)]) , 1] <-
                10
        
        data.table::setnames(dNdS_tbl_divMap, old = "dNdS", new = "divergence_strata")
        
        if (!subject.id)
                return(dNdS_tbl_divMap[ , list(divergence_strata, query_id)])
        if (subject.id)
                return(dNdS_tbl_divMap[ , list(divergence_strata, query_id, subject_id)])
}
