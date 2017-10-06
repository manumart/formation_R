setwd(homeS)
require(measurements)
require(zoo)
require(RODBC)
require(magrittr)
source("carbonModelling/scripts/R/Csopra/getDataCsopraAIAL.r")
source("carbonModelling/scripts/R/rmqsDyn/CsopraPlotFunctions.lib.r")
source("carbonModelling/scripts/R/classes/pathManagers.lib.r")
source("carbonModelling/scripts/R/classes/runners.lib.r")


#trts <- usm_ids[!(usm_ids %in% c(976,979,978,980, 981))] 

setwd(homeS)

source("carbonModelling/scripts/R/Csopra/getParametersCsopra.r")
connectName <- "dela.mayari"
db <- odbcConnect(connectName, case="postgresql",  believeNRows = F )
odbcQuery(db,paste("SET search_path=", ROOT_SCHEME, sep = ""))


sqlQuery(db,
 " DROP TABLE dm_csopra_simulations.aial_preds_yearly CASCADE ;
CREATE TABLE dm_csopra_simulations.aial_preds_yearly
  (
    id_profil_csopra integer,  -- Identifiant du profil CSopra 
    id_profil_aial character varying(255),  -- Identifiant du profil aial, c''est à dire le nom du traitement dans la base AIAL
    year integer, -- année d''observation
    csim double precision, -- valeur simulée (T/ha)
    model character varying(255) -- modèle utilisé
  )
  WITH (
    OIDS=FALSE
  );
  GRANT SELECT ON TABLE dm_csopra_simulations.aial_preds_yearly TO sid_user;
  ALTER TABLE dm_csopra_simulations.aial_preds_yearly OWNER TO mamartin;
  GRANT ALL ON SCHEMA dm_csopra_simulations TO bdimassi;
  GRANT ALL ON TABLE dm_csopra_simulations.aial_preds_yearly TO bdimassi;
  COMMENT ON TABLE dm_csopra_simulations.aial_preds_yearly
    IS 'résultats complets pour tous les modèles pour tous les traitements et toutes les années d''observation';
  COMMENT ON COLUMN dm_csopra_simulations.aial_preds_yearly.year IS 'année d''observation du SOC';
  COMMENT ON COLUMN dm_csopra_simulations.aial_preds_yearly.id_profil_aial IS 'Identifiant du profil aial, c''est à dire le nom du traitement dans la base AIAL';
  COMMENT ON COLUMN dm_csopra_simulations.aial_preds_yearly.id_profil_csopra IS 'Identifiant du profil CSopra';
  COMMENT ON COLUMN dm_csopra_simulations.aial_preds_yearly.csim IS 'valeur simulée (T/ha)';
  COMMENT ON COLUMN dm_csopra_simulations.aial_preds_yearly.model IS 'modèle utilisé';

"
)

### AMG ###
dataAMG <- read.csv("~/Desktop/Simulations AMGv1 & v2.csv", sep = ",", stringsAsFactors = F)

dataAMG$id_profil_csopra <- usmDataSite$id_profil_csopra[
					dataAMG$ID.Traitement %>% match(usmDataSite$id_profil_aial)
					]
dataAMG <- dataAMG[!is.na(dataAMG$id_profil_csopra) , ]
dataAMGSaved <- dataAMG[, c("id_profil_csopra", "ID.Traitement", "Annee", "Stock.de.carbone.simule")]
dataAMGSaved$model <- "AMG"
names(dataAMGSaved) <- c("id_profil_csopra", "id_profil_aial", "year", "csim", "model")


sqlSave(db, dataAMGSaved, tablename = "dm_csopra_simulations.aial_preds_yearly", rownames = F, append = T)
	
### ORCHIDEE
load("carbonModelling/data/simulationResults/ORCHIDEE/resOrchidee.RData")
resOrchidee$id_profil_csopra <- usmDataSite$id_profil_csopra[
					resOrchidee$traitement %>% match(usmDataSite$id_profil_aial)
					]
resOrchidee <- resOrchidee[, c(5, 3, 4, 2)]
resOrchidee$model <- "ORCHIDEE"
names(resOrchidee) <- c("id_profil_csopra", "id_profil_aial", "year", "csim", "model")
resOrchidee$csim <- resOrchidee$csim / 100
sqlSave(db, resOrchidee, tablename = "dm_csopra_simulations.aial_preds_yearly", rownames = F, append = T)


## Century & RothC
trts <- usmDataSite$id_profil_aial[!is.na(usmDataSite$id_profil_aial)]

resDf <- data.frame(id_profil_csopra = character(0), id_profil_aial = character(0),	year = numeric(0),
	pred = numeric(0), model = character(0),#	AMG = numeric(0), AMGDelta = numeric(0),
        stringsAsFactors = F)


for (namee in trts[]){

        simId <- usmDataSite$id_profil_csopra[match(namee, usmDataSite$id_profil_aial )]
	# unforced
	pm <- CenturyPathManager$new(simId, "")
	io <- CenturyIOReader$new(pm)
	binPath <- paste(homeS, pm$getResultDir(), "CenturyUnforcedlala", simId, sep = "")
	if (!file.exists(paste(binPath, ".bin", sep = ""))) next()
	CDyn <- io$readCenturyBinFile("somtc", 
	                                 binName = binPath, 
  			  		 rundir = RUNDIR)
	
	
	CDyn$Ctot <- CDyn[, "somtc"] 
	zCDyn <- monthlyZooFromRedBinFile(CDyn, "Ctot", F)

	zCDynUFY <- aggregate(zCDyn / CENTORCH_TO_AIAL ,  year(zCDyn), median)
	## to reproduce the slow relaxation constraint
	zCDynUFY[1] <- zCDyn[1] / CENTORCH_TO_AIAL
	timee <- time(zCDynUFY)

	tmp <- data.frame(zCDynUFY, timee)	
	tmp$id_profil_csopra <- 9999
	tmp$id_profil_aial <- namee
	tmp$model <- "CenturyUnforced"

	resDf <- rbind(resDf, tmp[, c(3, 4, 2, 1, 5)])

	binPath <- paste(homeS, pm$getResultDir(), "trialForcedlala", simId, sep = "")
	CDyn <- io$readCenturyBinFile("somtc", 
	                                 binName = binPath, 
  			  		 rundir = RUNDIR)

	CDyn$Ctot <- CDyn[, "somtc"] 
	zCDyn <- monthlyZooFromRedBinFile(CDyn, "Ctot", F)

	zCDynUFY <- aggregate(zCDyn / 100,  year(zCDyn), median)
	## to reproduce the slow relaxation constraint	
	zCDynUFY[1] <- zCDyn[1] / CENTORCH_TO_AIAL	
	timee <- time(zCDynUFY)

	tmp <- data.frame(zCDynUFY, timee)	
	tmp$id_profil_csopra <- 9999
	tmp$id_profil_aial <- namee
	tmp$model <- "Century"

	resDf <- rbind(resDf, tmp[, c(3, 4, 2, 1, 5)])

	## RothC
	pathManager <- PathManager$new(simId, "RothC", "RothC")
	load(paste(pathManager$getResultDir(), "CDyns.RData", sep = ""))

	if (length(timee) < 2 ){# length(time(CDynBaseUnitY))){ move only erroneous results
#	    browser()
	    print(namee)
	    next()
	}

	tmp <- data.frame(CDynBaseUnitY, time(CDynBaseUnitY))	
	tmp$id_profil_csopra <- 9999
	tmp$id_profil_aial <- namee
	tmp$model <- "RothC"

	resDf <- rbind(resDf, setNames(tmp[, c(3, 4, 2, 1, 5)], names(resDf)))

	## to reproduce the slow relaxation constraint
	CDynBaseUnitRelaxedY[1] <- CDynRelaxed$CTot[1]
	tmp <- data.frame(CDynBaseUnitRelaxedY, time(CDynBaseUnitRelaxedY))	
	tmp$id_profil_csopra <- 9999
	tmp$id_profil_aial <- namee
	tmp$model <- "RothCRelaxed"

	resDf <- rbind(resDf, setNames(tmp[, c(3, 4, 2, 1, 5)], names(resDf)))

}
table(resDf$model)
table(resDf$id_profil_aial)

names(resDf) <- c("id_profil_csopra", "id_profil_aial", "year", "csim", "model")
sqlQuery(db, "DELETE FROM dm_csopra_simulations.aial_preds_yearly 
	      WHERE model LIKE 'Century%' OR model LIKE 'RothC%'");
sqlSave(db, resDf, tablename = "dm_csopra_simulations.aial_preds_yearly", rownames = F, append = T)


### IPCC

trts <- usmDataSite$id_profil_aial[!is.na(usmDataSite$id_profil_aial)]
resDf <- data.frame(id_profil_csopra = character(0), id_profil_aial = character(0),
	   year = numeric(0), pred = numeric(0), model = character(0),
        stringsAsFactors = F)

for (namee in trts[]){

        simId <- usmDataSite$id_profil_csopra[match(namee, usmDataSite$id_profil_aial )]

  # unforced
	pm <- PathManager$new(simId, "IPCCTier1", "")

	fileName <- paste(pm$getResultDir(), "Tier1CDyns.RData", sep = "")
	if (!file.exists(fileName)) {
	  	next()
	} else {
		load(fileName)
	}
	#if (length(timee) != length(time(CDynBaseUnitY))) next()

	tmp <- data.frame(CDyn, as.numeric(names(CDyn)))	
	tmp$id_profil_csopra <- simId
	tmp$id_profil_aial <- namee
	tmp$model <- "IPCCTier1"

	resDf <- rbind(resDf, setNames(tmp[, c(3, 4, 2, 1, 5)], names(resDf)))

}
table(resDf$model)


names(resDf) <- c("id_profil_csopra", "id_profil_aial", "year", "csim", "model")
sqlQuery(db, "DELETE FROM dm_csopra_simulations.aial_preds_yearly 
	      WHERE model LIKE 'IPCC%'");
sqlSave(db, resDf, tablename = "dm_csopra_simulations.aial_preds_yearly", rownames = F, append = T)




### PKs from IPCC

trts <- usmDataSite$id_profil_aial[!is.na(usmDataSite$id_profil_aial)]
resDf <- data.frame(id_profil_csopra = character(0), id_profil_aial = character(0),
	    year = numeric(0),
	 omad = character(0), 
	 labour = numeric(0), residus = numeric(0), cultInter = numeric(0), 
	 cultOSRLike = numeric(0),
         omad6 = character(0), 
	 labour6 = numeric(0), residus6 = numeric(0), cultInter6 = numeric(0), 
	 cultOSRLike6 = numeric(0),
         omad9 = character(0), 
	 labour9 = numeric(0), residus9 = numeric(0), cultInter9 = numeric(0), 
	 cultOSRLike9 = numeric(0),
        stringsAsFactors = F)

resDfClim <- data.frame(id_profil_csopra = character(0), id_profil_aial = character(0),
	    year = numeric(0),
	 tmin = character(0), 
	 tmax = numeric(0),
	 rain = numeric(0), 
	 etp = numeric(0)
)

for (namee in trts[]){

        simId <- usmDataSite$id_profil_csopra[match(namee, usmDataSite$id_profil_aial )]
	pm <- PathManager$new(simId, "IPCCTier1", "")

	fileName <- paste(pm$getResultDir(), "Tier1CDyns.RData", sep = "")
	if (!file.exists(fileName)) {
	  	next()
	} else {
		load(fileName)
	}
	#if (length(timee) != length(time(CDynBaseUnitY))) next()

	tmp <- data.frame(pksY)	
	tmp$year <- year(time(pksY))
	tmp$id_profil_csopra <- 9999
	tmp$id_profil_aial <- namee
	names(pksY6) <- paste(names(pksY6), "6", sep = "")
	names(pksY9) <- paste(names(pksY9), "9", sep = "")
        tmp <- cbind(tmp, coredata(pksY6), coredata(pksY9))
	tmp <- left_join(tmp, yearlyMeteo[, ], by = c("year" = "time"))
	resDf <- rbind(resDf, tmp[, c(9, 10, 8, 1:5, 11:20)])
	resDfClim <- rbind(resDfClim, tmp[, c(9, 10, 8, 11:14)])


}

# names(resDf) <- resDf[, c("id_profil_csopra", "id_profil_aial", "year", "omad", "labour", "residus", 
# 			"cultInter", "cultOSRLike")]
sqlDrop(db, "dm_csopra_simulations.aial_pks_stats")
sqlSave(db, resDf, tablename = "dm_csopra_simulations.aial_pks_stats", rownames = F)

sqlDrop(db, "dm_csopra_simulations.aial_climate_stats")
sqlSave(db, resDfClim, tablename = "dm_csopra_simulations.aial_climate_stats", rownames = F)





# crée les vues pour utilisation ultérieures
sqlQ <- readChar("carbonModelling/scripts/sql/Csopra/SimulResultsView.sql", nchars=1e6)
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


#deltaC
p <- ggplot(data = predObs, aes(x = deltasocobs, y = deltasocsim))  + geom_abline(intercept = 10 * (-1:1), color = "grey", slope = 1) +
     geom_point(aes(text = paste("lala:", year)))+
     geom_line(aes(color = id_profil_aial), size = 0.3, arrow = arrow(length = unit(0.1,"cm")))+
     geom_segment(aes(xend=deltasocobs, yend=deltasocsim, color = id_profil_aial), size = 0.3, arrow = arrow(length = unit(0.1,"cm")))+
#     geom_smooth() +
     facet_wrap(~ model)
ggplotly(p)

##C
p <- ggplot(data = predObs, aes(x = cobs, y = csim))  + geom_abline(intercept = 10 * (-1:1), color = "grey", slope = 1) +
     geom_point(aes(text = paste("lala:", year)))+
     geom_line(aes(color = id_profil_aial), size = 0.3, arrow = arrow(length = unit(0.1,"cm")))+
     geom_segment(aes(xend=cobs, yend=csim, color = id_profil_aial), size = 0.3, arrow = arrow(length = unit(0.1,"cm")))+
#     geom_smooth() +
     facet_wrap(~ model)
ggplotly(p)


