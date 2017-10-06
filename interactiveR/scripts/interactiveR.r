setwd(homeS)
require(measurements)
require(zoo)
require(RODBC)
require(magrittr)


connectName <- "dela.mayari"
db <- odbcConnect(connectName, case="postgresql",  believeNRows = F )
odbcQuery(db,paste("SET search_path=", ROOT_SCHEME, sep = ""))


sqlQuery(db, sqlQ)
predObs <- sqlQuery(db, "SELECT * FROM dm_csopra_simulations.predObs_AIAL
		    WHERE model <> 'ORCHIDEE'
")
require(ggplot2)
require(plotly)
predObs$site <- substr(predObs$id_profil_aial, 1, 2)

p <- 
  ggplot(predObs, aes(cobs, csim)) + 
     geom_point(aes(text = paste("site:", id_profil_aial)))+
     facet_grid(site~.) + geom_abline(intercept = 0, slope = 1)
     
ggplotly(p)

demoDF <- predObs[, c("deltasocsim", "deltasocobs", "year", "id_profil_aial", "model")]

save(demoDF, file = "~/demoDF")

load("~/demoDF")

#deltaC
p <- ggplot(data = demoDF, aes(x = deltasocobs, y = deltasocsim))  + geom_abline(intercept = 10 * (-1:1), color = "grey", slope = 1) +
     geom_point(aes(text = paste("lala:", year)))+
     geom_line(aes(color = id_profil_aial), size = 0.3, arrow = arrow(length = unit(0.1,"cm")))+
     geom_segment(aes(xend=deltasocobs, yend=deltasocsim, color = id_profil_aial), size = 0.3, arrow = arrow(length = unit(0.1,"cm")))+
#     geom_smooth() +
     facet_wrap(~ model)
ggplotly(p)


