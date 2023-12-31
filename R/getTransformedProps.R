#' Calculates and transforms cell type proportions
#'
#' Calculates cell types proportions based on clusters/cell types and sample
#' information and performs a variance stabilising transformation on the
#' proportions.
#'
#' This function is called by the \code{propeller} function and calculates cell
#' type proportions and performs an arcsin-square root transformation.
#'
#' @param clusters a factor specifying the cluster or cell type for every cell.
#' @param sample a factor specifying the biological replicate for every cell.
#' @param transform a character scalar specifying which transformation of the 
#' proportions to perform. Possible values include "asin" or "logit". Defaults
#' to "asin".
#' 
#' @return outputs a list object with the following components
#' \item{Counts }{A matrix of cell type counts with
#' the rows corresponding to the clusters/cell types and the columns
#' corresponding to the biological replicates/samples.}
#' \item{TransformedProps }{A matrix of transformed cell type proportions with
#' the rows corresponding to the clusters/cell types and the columns
#' corresponding to the biological replicates/samples.} 
#' \item{Proportions }{A  matrix of cell type proportions with the rows 
#' corresponding to the clusters/cell types and the columns corresponding to 
#' the biological replicates/samples.}
#'
#' @export
#'
#' @author Belinda Phipson
#'
#' @seealso \code{\link{propeller}}
#'
#' @examples
#'
#'   library(speckle)
#'   library(ggplot2)
#'   library(limma)
#'
#'   # Make up some data
#'
#'   # True cell type proportions for 4 samples
#'   p_s1 <- c(0.5,0.3,0.2)
#'   p_s2 <- c(0.6,0.3,0.1)
#'   p_s3 <- c(0.3,0.4,0.3)
#'   p_s4 <- c(0.4,0.3,0.3)
#'
#'   # Total numbers of cells per sample
#'   numcells <- c(1000,1500,900,1200)
#'
#'   # Generate cell-level vector for sample info
#'   biorep <- rep(c("s1","s2","s3","s4"),numcells)
#'   length(biorep)
#'
#'   # Numbers of cells for each of 3 clusters per sample
#'   n_s1 <- p_s1*numcells[1]
#'   n_s2 <- p_s2*numcells[2]
#'   n_s3 <- p_s3*numcells[3]
#'   n_s4 <- p_s4*numcells[4]
#'
#'   cl_s1 <- rep(c("c0","c1","c2"),n_s1)
#'   cl_s2 <- rep(c("c0","c1","c2"),n_s2)
#'   cl_s3 <- rep(c("c0","c1","c2"),n_s3)
#'   cl_s4 <- rep(c("c0","c1","c2"),n_s4)
#'
#'   # Generate cell-level vector for cluster info
#'   clust <- c(cl_s1,cl_s2,cl_s3,cl_s4)
#'   length(clust)
#'
#'   getTransformedProps(clusters = clust, sample = biorep)
#'
getTransformedProps <- function(clusters=clusters, sample=sample, 
                                transform=NULL)
{
    if(is.null(transform)) transform <- "logit"

    tab <- table(sample, clusters)
    props <- tab/rowSums(tab)
    if(transform=="asin"){
        message("Performing arcsin square root transformation of proportions")
        prop.trans <- asin(sqrt(props))
    }
    else if(transform=="logit"){
        message("Performing logit transformation of proportions")
        props.pseudo <- (tab+0.5)/rowSums(tab+0.5)
        prop.trans <- log(props.pseudo/(1-props.pseudo))
    }
    return(list(Counts=t(tab), TransformedProps=t(prop.trans), 
                Proportions=t(props)))
}
