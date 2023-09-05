library(ggplot2)

data(diamonds)

head(diamonds)

View(diamonds)

d <- diamonds[sample(nrow(diamonds), 2000), ]


ggplot(data = d,
        aes(x = carat, y = price, col = carat, size = carat)) + 
        geom_point()
