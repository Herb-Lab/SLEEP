#1. Data preparation-----
x_data <- read_csv("Data.csv") # The data that support the findings of this study are available on request from the corresponding author

#2. PCA-----
# Standardize the data before PCA
x_data_scaled <- scale(x_data)

# Perform PCA
pca_result <- prcomp(x_data_scaled, center = TRUE, scale. = TRUE)

# Summary of PCA
summary(pca_result)

# Visualize explained variance
fviz_eig(pca_result)

## Create a PCA biplot-----
fviz_pca_biplot(
  pca_result,
  axes = c(1, 2), # Specify PC1 and PC2
  geom = "point",
  label = "var",
  repel = TRUE,
  col.ind = df_very_risk_encoded$combined_risk, # Match the dataset
  palette = "Set2",
  pointsize = 0.5, # Make points smaller
  labelsize = 3, # Adjust text size if needed
  col.var = "black" # Make text (variable labels) black
)+
  scale_color_manual(values = c(
    "Very high" = "#c0392b",
    "Very low" = "#2ecc71"
  ))

fviz_pca_biplot(
  pca_result,
  axes = c(1, 3), # Specify PC1 and PC2
  geom = "point",
  label = "var",
  repel = TRUE,
  col.ind = df_very_risk_encoded$combined_risk, # Match the dataset
  palette = "Set2",
  pointsize = 0.5, # Make points smaller
  labelsize = 3, # Adjust text size if needed
  col.var = "black" # Make text (variable labels) black
)+
  scale_color_manual(values = c(
    "Very high" = "#F57A51",
    "Very low" = "#6DDC8E"
  ))

fviz_pca_biplot(
  pca_result,
  axes = c(2, 3), # Specify PC2 and PC3
  geom = "point",
  label = "var",
  repel = TRUE,
  col.ind = df_very_risk_encoded$combined_risk, # Match the dataset
  palette = "Set2",
  pointsize = 0.5, # Make points smaller
  labelsize = 3, # Adjust text size if needed
  col.var = "black" # Make text (variable labels) black
) +
  scale_color_manual(values = c(
    "Very high" = "#F57A51",
    "Very low" = "#6DDC8E"
  ))

