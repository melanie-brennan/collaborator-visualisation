# Install and load package
#install.packages("igraph")
library(igraph)

# Load data
graph_data <- read.table("CA-GrQc.txt")

# Create graph
g <- graph.data.frame(graph_data[,1:2], directed =TRUE)

# Some statistic about the whole graph, g
# Number of nodes
length(V(g))

# Number of edges
length(E(g))

# Degree statistics - all
table(degree(g, mode = "all"))
summary(degree(g, mode = "all"))

# Degree statisics - outgoing
table(degree(g, mode = "out"))
summary(degree(g, mode = "out"))

# Degree statisics - incoming
table(degree(g, mode = "in"))
summary(degree(g, mode = "in"))

# Degree statisics - total
table(degree(g, mode = "total"))
summary(degree(g, mode = "total"))

# Get id and the name of the node with the maximum degree
# Use just the outgoing edges
max_degree_node <- V(g)[degree(g, mode="out")==max(degree(g, mode ="out") )]
max_degree_node_name <- V(g)$name[degree(g, mode="out")==max(degree(g, mode ="out") )]

# Find the nodes that neighbour the node with the maximum incoming edges
neighbor_nodes <- neighbors(g, v=max_degree_node)

# Subset the node to just the maximum degree node and its incoming neighbours
n <- induced_subgraph(g, c(max_degree_node, neighbor_nodes))

# Begin to remove the edges between neighbours (except the node with maximum degree)
# Get a vector of names of the edges starting node 
E(n)$start <- ends(n, es=E(n), names=T)[,1]

# Set an attribute, incoming, that contains the original degree of all the nodes in n
V(n)$outgoing = degree(n, mode="out")

# Find all edhes that don't start at the maximum node, then delete them
not_joined_to_max_indices <-which(E(n)$start!=max_degree_node_name)
not_joined_to_max_edges <- E(n)[not_joined_to_max_indices]
n <-delete_edges(n, not_joined_to_max_edges)

# Plot a graph showing who the biggest collaborator collaborates with
# Prepare to plot
divisor = 3 # the divisor reduces the size of the plots labels
V(n)$size <- V(n)$outgoing /divisor

# If the node is the maximum node, make it and its outline blue, otherwise orange
V(n)$color <- ifelse(V(n)$name == max_degree_node_name, "lightblue", "orange")
V(n)$frame.color <- ifelse(V(n)$name == max_degree_node_name, "lightblue", "orange")

# Style the arrows
E(n)$arrow.size = 0.3
E(n)$color.arrow= "black"

# Style the labels
V(n)$label.cex = 0.8

# Set seed so exact plot can be reproduced - 44 gave a nice looking graph
set.seed(44) 

# Create a file name and open a png file
filename <- paste("graph_collaborators_id.png", sep="")
png(filename, width=720, height = 630)

# Plot the graph using the node names as node labels
plot <- plot(n, vertex.label.color="black", main="Graph of researcher 21012's collaborators", 
             sub="Nodes represent authors and are labelled with author ID") 

# Display  the plot
print(plot)

# Close the png file
dev.off()

# Plot another graph displaying the number of collaborators 
filename <- paste("graph_collaborators_numbers.png", sep="")
png(filename, width=720, height = 630)

# Use the same seed again so nodes are placed in the same position
set.seed(44) 

# Plot the graph using incoming node degree as the label
V(n)$label = V(n)$outgoing
plot(n, vertex.label.color="black", main="Graph of researcher 21012's collaborators", 
     sub="Nodes represent authors and are labelled with the number of their collaborators") 

# Display  the plot
print(plot)

# Close the png file
dev.off()