library(R6)

Profil <- R6Class("Profil",
  public = list(
    name = NULL,
    horizons = NULL, ## a data.frame
    depth = NULL,
    initialize = function(horizons = NA, depth = NA, name = NA) {
      self$name <- name
      self$horizons <- horizons
      self$depth <- depth
      self$greet()
    },
    greet = function() {
      cat(paste0("Hello, my name is ", self$name, ".\n"))
    },
    setMetadata = function(texte){
	private$metadata <- texte
    }
  ),
  private = list(
	metadata = NULL
  )
)
prof <- Profil$new(depth = 40, name = "very first one")
prof$setMetadata("ce profil est localisé chez Monsieur alambic")

horizons <- data.frame(tops = c(0, 5, 15), bottoms = c(5, 15, 30),
                       carbon = c(13, 2.5, 1.2))
prof$horizons <- horizons

### with plotting methods
Profil <- R6Class("Profil",
  public = list(
    name = NULL,
    horizons = NULL, ## a data.frame
    depth = NULL,
    initialize = function(horizons = NA, depth = NA, name = NA) {
      self$name <- name
      self$horizons <- horizons
      self$depth <- depth
    },
    plot = function(){
	plot(0,1, col = "white", xaxt = 'n',
             xlim = c(0, ceiling(max(self$horizons$carbon))),
             ylim = c(self$depth, 0))
	axis(3)
	rect(rep(0, 4), self$horizons$bottoms, self$horizons$carbon,
	     self$horizons$tops, col = "brown")
    }
  ),
)


prof <- Profil$new(horizons = horizons, depth = 40,
                   name = "very first one")
prof$plot()



require(infosolR)

### with splines
ProfilWithSplines <- R6Class("ProfilWithSplines",
    inherit = Profil,
    public = list(
    splinee = NULL,
    initialize = function(horizons = NA, depth = NA, name = NA) {
      super$initialize(horizons, depth, name)
      self$splinee <- fitSpline(self$horizons$carbon,
	 			self$horizons$tops,
				self$horizons$bottoms,
				lambda = 0.5)
    },
    plot = function(){
	super$plot()
	depths <- (self$horizons$bottoms + self$horizons$tops) / 2
	lines(predSpline(0:max(depths), self$splinee),
                         (0:max(depths)))
    }
  )
)


profWithSpline <- ProfilWithSplines$new(horizons = horizons, depth = 40,
                                        name = "very first one")
profWithSpline$plot()

