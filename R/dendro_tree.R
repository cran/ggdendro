#
#  ggdendro/R/dendro_tree.R by Andrie de Vries  Copyright (C) 2011-2013
#  Contains code from tree/R/tree.R by B. D. Ripley  Copyright (C) 1994-2012
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 or 3 of the License
#  (at your option).
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#  GNU General Public License for more details.
#
#  A copy of the GNU General Public License is available at
#  http://www.r-project.org/Licenses/
#
#


#' Extract data from regression tree object for plotting using ggplot.
#' 
#' Extracts data to plot line segments and labels from a \code{\link[tree]{tree}} object.  This data can then be manipulated or plotted, e.g. using \code{\link[ggplot2]{ggplot}}.
#' 
#' @param model object of class "tree", e.g. the output of tree()
#' @param ... ignored
#' @method dendro_data tree
#' @export
#' @return
#' A list of three data frames:
#' \item{segments}{a data frame containing the line segment data}
#' \item{labels}{a data frame containing the label text data}
#' \item{leaf_labels}{a data frame containing the leaf label text data}
#' @seealso \code{\link{ggdendrogram}}
#' @family dendro_data methods
#' @family tree functions
#' @author Andrie de Vries, using code modified from original by Brian Ripley
#' @examples
#' require(tree)
#' require(ggplot2)
#' require(MASS)
#' data(cpus, package="MASS")
#' cpus.ltr <- tree(log10(perf) ~ syct+mmin+mmax+cach+chmin+chmax, cpus)
#' tree_data <- dendro_data(cpus.ltr)
#' ggplot(segment(tree_data)) +
#' 	geom_segment(aes(x=x, y=y, xend=xend, yend=yend, size=n), 
#' 		colour="blue", alpha=0.5) +
#' 	scale_size("n") +
#' 	geom_text(data=label(tree_data), 
#' 		aes(x=x, y=y, label=label), vjust=-0.5, size=4) +
#' 	geom_text(data=leaf_label(tree_data), 
#' 		aes(x=x, y=y, label=label), vjust=0.5, size=3) +
#'  theme_dendro()
dendro_data.tree <- function(model, ...){
	labels <- tree_labels(model, ...)
	as.dendro(
    segments = tree_segments(model, ...),
		labels = labels$labels,
		leaf_labels = labels$leaf_labels,
    class="tree"
	)
}



#' Extract data frame from tree object for plotting using ggplot.
#' @param model object of class "tree", e.g. the output of tree()
#' @param ... ignored
#' @keywords internal
#' @seealso \code{\link{ggdendrogram}}
#' @family tree functions
#' @author Code modified from original by Brian Ripley
tree_segments <- function(model, ...){
	# Uses tree:::treeco to extract data frame of plot locations
	xy <- tree:::treeco(model)
	n <- model$frame$n
	
	# Lines copied from tree:::treepl
	x <- xy$x
	y <- xy$y
	node = as.numeric(row.names(model$frame))
	parent <- match((node%/%2), node)
	sibling <- match(ifelse(node%%2, node - 1L, node + 1L), node)
	
	linev <- data.frame(x=x, y=y, xend=x, yend=y[parent], n=n)
	lineh <- data.frame(x=x[parent], y=y[parent], xend=x, yend=y[parent], n=n)
	
	rbind(linev[-1,], lineh[-1,])
}

#' Extract labels data frame from tree object for plotting using ggplot.
#' @param model object of class "tree", e.g. the output of tree()
#' @param ... ignored
#' @return a list with two elements: $labels and $leaf_labels
#' @keywords internal
#' @seealso \code{\link{ggdendrogram}}
#' @family tree functions
#' @author Code modified from original by Brian Ripley
tree_labels <- function(model, ...){
  # Uses tree:::treeco to extract data frame of plot locations
  xy <- tree:::treeco(model)
  label <- model$frame$var
	yval  <- model$frame$yval
	sleft  <- model$frame$splits.cutleft
  sright <- model$frame$splits.right

  # Lines copied from tree:::treepl
  x <- xy$x
  y <- xy$y
  node = as.numeric(row.names(model$frame))
  parent <- match((node%/%2), node)
  sibling <- match(ifelse(node%%2, node - 1L, node + 1L), node)

	# Extract labels
  data <- data.frame(x=x, y=y, label=label)
  data <- data[data$label != "<leaf>",]
	labels <- as.data.frame(data)
	
	# Extract leaf labels
	data <- data.frame(x, y, label, yval)
	data <- data[data$label == "<leaf>",]
  if(is.numeric(data$yval)){
	  data$label <- round(data$yval, 2)
  } else {
    data$label <- data$yval
  }
	leaf_labels <- as.data.frame(data)
	
	list(
			labels      = labels,
			leaf_labels = leaf_labels
	)
}

#' Extract labels data frame from tree object for plotting using ggplot.
#' 
#' Extract labels data frame from tree object for plotting using ggplot
#' 
#' @param model object of class "tree", e.g. the output of tree()
#' @param ... ignored
#' @keywords internal
#' @seealso \code{\link{ggdendrogram}}
#' @family tree functions
#' @author Code modified from original by Brian Ripley
get_data_tree_leaf_labels <- function(model, ...){
  # Uses tree:::treeco to extract data frame of plot locations
  xy <- tree:::treeco(model)
  label <- model$frame$var
  yval  <- model$frame$yval
  sleft  <- model$frame$splits.cutleft
  sright <- model$frame$splits.right

  # Lines copied from tree:::treepl
  x <- xy$x
  y <- xy$y
  node = as.numeric(row.names(model$frame))
  parent <- match((node%/%2), node)
  sibling <- match(ifelse(node%%2, node - 1L, node + 1L), node)

  data <- data.frame(x, y, label, yval)
  data <- data[data$label == "<leaf>",]
  data$label <- round(data$yval, 2)
  data
}

