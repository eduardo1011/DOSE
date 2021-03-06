##' mapping geneID to gene Symbol
##'
##'
##' @title setReadable
##' @param x enrichResult Object
##' @param OrgDb OrgDb
##' @param keytype keytype of gene
##' @return enrichResult Object
##' @author Yu Guangchuang
##' @export
setReadable <- function(x, OrgDb, keytype="auto") {
    OrgDb <- load_OrgDb(OrgDb)
    if (!'SYMBOL' %in% columns(OrgDb)) {
        warning("Fail to convert input geneID to SYMBOL since no SYMBOL information available in the provided OrgDb...")
    }

    if (!(is(x, "enrichResult") || is(x, "groupGOResult") || is(x, "gseaResult")))
        stop("input should be an 'enrichResult' or 'gseaResult' object...")

    isGSEA <- FALSE
    if (is(x, 'gseaResult'))
        isGSEA <- TRUE

    if (keytype == "auto") {
        keytype <- x@keytype
        if (keytype == 'UNKNOWN') {
            stop("can't determine keytype automatically; need to set 'keytype' explicitly...")
        }
    }

    if (x@readable)
        return(x)

    gc <- geneInCategory(x)

    if (isGSEA) {
        genes <- names(x@geneList)
    } else {
        genes <- x@gene
    }

    gn <- EXTID2NAME(OrgDb, genes, keytype)
    gc <- lapply(gc, function(i) gn[i])

    res <- x@result
    gc <- gc[as.character(res$ID)]
    geneID <- sapply(gc, paste0, collapse="/")
    if (isGSEA) {
        res$core_enrichment <- unlist(geneID)
    } else {
        res$geneID <- unlist(geneID)
    }

    x@gene2Symbol <- gn
    x@result <- res
    x@keytype <- keytype
    x@readable <- TRUE

    return(x)
}
