#1. Data preparation-----
merged_df <- read_csv("Data.csv") # The data that support the findings of this study are available on request from the corresponding author

#2. KL divergence-----
##Hierarchical Clustering to group cities-----
generate_kl_heatmap <- function(df, col_name) {
  if (!col_name %in% names(df)) stop("The specified column does not exist in the data frame.")
  
  city_kde <- df %>%
    group_by(City) %>%
    summarise(
      kde = list(density(get(col_name), bw = 0.5, na.rm = TRUE))  # Fixed bandwidth
    )
  
  cities <- as.character(city_kde$City)
  #cities <- city_kde$City
  kl_divergence <- function(kde1, kde2) {
    common_x <- seq(min(kde1$x, kde2$x), max(kde1$x, kde2$x), length.out = 1000)
    p <- approx(kde1$x, kde1$y, xout = common_x, rule = 2)$y
    q <- approx(kde2$x, kde2$y, xout = common_x, rule = 2)$y
    p[p == 0] <- 1e-10
    q[q == 0] <- 1e-10
    sum(p * log(p / q)) * diff(common_x)[1]
  }
  
  kl_matrix <- outer(
    1:length(cities), 1:length(cities),
    Vectorize(function(i, j) {
      if (i == j) return(0)
      kl_divergence(city_kde$kde[[i]], city_kde$kde[[j]])
    })
  )
  
  dimnames(kl_matrix) <- list(cities, cities)
  
  row_clusters <- hclust(as.dist(kl_matrix), method = "centroid")
  col_clusters <- hclust(as.dist(kl_matrix), method = "centroid")
  
  pheatmap(
    kl_matrix,
    cluster_rows = row_clusters,
    cluster_cols = col_clusters,
    color = colorRampPalette(c("white", "#B9DDF1", "#376491"))(10),
    display_numbers = FALSE,
    fontsize = 8,
    fontsize_row = 8,
    fontsize_col = 8,
    treeheight_row = 0,
    treeheight_col = 15
  )
}

# Call the function with the data frame and column name
p <- generate_kl_heatmap(merged_df, "Annual_EMS.OSA5_prob_1_mean")
ggsave("KL_heatmap_OSA.png", plot = p, width = 3.5, height = 3, dpi = 300, bg="transparent")
p <- generate_kl_heatmap(merged_df, "Annual_EMS.OSA5_prob_2_mean")
ggsave("KL_heatmap_OSA_obesity.png", plot = p, width = 3.5, height = 3, dpi = 300, bg="transparent")
p <- generate_kl_heatmap(merged_df, "Annual_EMS.SE85_prob_1_mean")
ggsave("KL_heatmap_SE.png", plot = p, width = 3.5, height = 3, dpi = 300, bg="transparent")



