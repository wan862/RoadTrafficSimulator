'use strict'

{random} = Math
require '../helpers'
_ = require 'underscore'
Car = require './car'
Intersection = require './intersection'
Road = require './road'
Pool = require './pool'
Rect = require '../geom/rect'
settings = require '../settings'

class World
  constructor: ->
    @set {}

  @property 'instantSpeed',
    get: ->
      speeds = _.map @cars.all(), (car) -> car.speed
      return 0 if speeds.length is 0
      return (_.reduce speeds, (a, b) -> a + b) / speeds.length

  set: (obj) ->
    obj ?= {}
    @intersections = new Pool Intersection, obj.intersections
    @roads = new Pool Road, obj.roads
    @cars = new Pool Car, obj.cars
    @carsNumber = 0
    @time = 0

  save: ->
    data = _.extend {}, this
    delete data.cars
    localStorage.world = JSON.stringify data

  load: (data) ->
    data = data or localStorage.world
    data = data and JSON.parse data
    return unless data?
    @clear()
    @carsNumber = data.carsNumber or 0
    for id, intersection of data.intersections
      @addIntersection Intersection.copy intersection
    for id, road of data.roads
      road = Road.copy road
      road.source = @getIntersection road.source
      road.target = @getIntersection road.target
      @addRoad road

  generateMap: (minX = -4, maxX = 5, minY = -2, maxY = 2) ->
    @clear()
    intersectionsNumber = (0.8 * (maxX - minX + 1) * (maxY - minY + 1)) | 0
    map = {}
    gridSize = settings.gridSize
    step = 5 * gridSize
    @carsNumber = 100

    # while intersectionsNumber > 0
    #   x = _.random minX, maxX
    #   y = _.random minY, maxY
    #   console.log('x=', x, '|y=', y)
    #   unless map[[x, y]]?
    #     rect = new Rect step * x, step * y, gridSize, gridSize
    #     intersection = new Intersection rect
    #     @addIntersection map[[x, y]] = intersection
    #     intersectionsNumber -= 1
    intersectionXY = [
      [6,-3],
      [-5,-2], [-4,-2], [-3,-2], [-2,-2], [2,-2], [4,-2],[5,-2],[6,-2], [7,-2]
      [-2,-1], [2,-1],
      [0,0], [4,0], [5,0], [6,0], 
      [-4,1], [-3,1],
      [-5,2], [-4,2], [6,2],[7,2],
      [6,3]
    ]
    for p in intersectionXY
      x = p[0]
      y = p[1]
      rect = new Rect step * x, step * y, gridSize, gridSize
      intersection = new Intersection rect
      @addIntersection map[[x, y]] = intersection

    # bukit timah road
    @roadBukitTimah1 = new Road map[[7,-2]], map[[6,-2]], 3
    @addRoad @roadBukitTimah1
    @roadBukitTimah2 = new Road map[[6,-2]], map[[5,-2]], 3
    @addRoad @roadBukitTimah2
    @roadBukitTimah3 = new Road map[[5,-2]], map[[4,-2]], 3
    @addRoad @roadBukitTimah3
    @roadBukitTimah4 = new Road map[[4,-2]], map[[2,-2]], 3
    @addRoad @roadBukitTimah4
    @addRoad new Road map[[2,-2]], map[[-2,-2]], 3
    @addRoad new Road map[[-2,-2]], map[[-3,-2]], 3
    @addRoad new Road map[[-3,-2]], map[[-4,-2]], 3
    @addRoad new Road map[[-4,-2]], map[[-5,-2]], 3
    # holland road
    @addRoad new Road map[[-5,2]], map[[-4,2]], 4 
    @addRoad new Road map[[-4,2]], map[[-5,2]], 4 
    @roadHolland3 = new Road map[[-4,2]], map[[6,2]], 4 
    @addRoad @roadHolland3
    @roadHolland4 = new Road map[[6,2]], map[[-4,2]], 4
    @addRoad @roadHolland4
    @addRoad new Road map[[6,2]], map[[7,2]], 4
    @addRoad new Road map[[7,2]], map[[6,2]], 4
    # sixth aventh
    @addRoad new Road map[[-4,-2]], map[[-4,1]], 2
    @addRoad new Road map[[-4,1]], map[[-4,-2]], 2
    @addRoad new Road map[[-4,1]], map[[-4,2]], 2
    @roadSixAve4 = new Road map[[-4,2]], map[[-4,1]], 2
    @addRoad @roadSixAve4
    # adam road
    @addRoad new Road map[[6,-3]], map[[6,-2]], 4
    @addRoad new Road map[[6,-2]], map[[6,-3]], 4
    @addRoad new Road map[[6,-2]], map[[6,0]], 4
    @roadAdam4 = new Road map[[6,0]], map[[6,-2]], 4
    @addRoad @roadAdam4
    @roadAdam5 = new Road map[[6,0]], map[[6,2]], 4
    @addRoad @roadAdam5
    @addRoad new Road map[[6,2]], map[[6,0]], 4
    @addRoad new Road map[[6,2]], map[[6,3]], 4
    @addRoad new Road map[[6,3]], map[[6,2]], 4
    # namly road
    @addRoad new Road map[[-3,-2]], map[[-3,1]], 1
    @roadNamlyRoad2 = new Road map[[-3,1]], map[[-3,-2]], 1
    @addRoad @roadNamlyRoad2
    @addRoad new Road map[[-3,1]], map[[-4,1]], 1
    @roadNamlyRoad4 = new Road map[[-4,1]], map[[-3,1]], 1
    @addRoad @roadNamlyRoad4
    # hci circular
    #@addRoad new Road map[[-2,-2]], map[[-2,-1]], 1
    @addRoad new Road map[[-2,-1]], map[[-2,-2]], 1
    #@addRoad new Road map[[-2,-1]], map[[0,0]], 1
    @addRoad new Road map[[0,0]], map[[-2,-1]], 1

    @addRoad new Road map[[2,-2]], map[[2,-1]], 1
    #@addRoad new Road map[[2,-1]], map[[2,-2]], 1
    @addRoad new Road map[[2,-1]], map[[0,0]], 1
    #@addRoad new Road map[[0,0]], map[[2,-1]], 1
    # king's road
    @addRoad new Road map[[4,-2]], map[[4,0]], 1
    @addRoad new Road map[[4,0]], map[[4,-2]], 1
    @addRoad new Road map[[4,0]], map[[5,0]], 1
    @addRoad new Road map[[5,0]], map[[4,0]], 1
    # queen's road
    @addRoad new Road map[[5,-2]], map[[5,0]], 1
    @addRoad new Road map[[5,0]], map[[5,-2]], 1
    @addRoad new Road map[[5,0]], map[[6,0]], 1
    @addRoad new Road map[[6,0]], map[[5,0]], 1
    # for x in [minX..maxX]
    #   previous = null
    #   for y in [minY..maxY]
    #     intersection = map[[x, y]]
    #     if intersection?
    #       if random() < 0.9
    #         @addRoad new Road intersection, previous if previous?
    #         @addRoad new Road previous, intersection if previous?
    #       previous = intersection
    # for y in [minY..maxY]
    #   previous = null
    #   for x in [minX..maxX]
    #     intersection = map[[x, y]]
    #     if intersection?
    #       if random() < 0.9
    #         @addRoad new Road intersection, previous if previous?
    #         @addRoad new Road previous, intersection if previous?
    #       previous = intersection
    null


  clear: ->
    @set {}

  onTick: (delta) =>
    throw Error 'delta > 1' if delta > 1
    @time += delta
    @refreshCars()
    for id, intersection of @intersections.all()
      intersection.controlSignals.onTick delta
    for id, car of @cars.all()
      car.move delta
      @removeCar car unless car.alive

  refreshCars: ->
    @addCar new Car @roadBukitTimah2.leftmostLane
    @addCar new Car @roadBukitTimah4.leftmostLane
    # @addCar new Car @roadBukitTimah4.leftmostLane
    # @addCar new Car @roadSixAve4.leftmostLane
    @addCar new Car @roadNamlyRoad2.leftmostLane
    @addCar new Car @roadAdam4.leftmostLane
    # @addCar new Car @roadAdam5.leftmostLane
    @addCar new Car @roadHolland3.leftmostLane
    @addCar new Car @roadHolland4.leftmostLane
    # @addCar new Car @roadAdam4.leftmostLane
    @addRandomCar() if @cars.length < @carsNumber
    @removeRandomCar() if @cars.length > @carsNumber

  addRoad: (road) ->
    @roads.put road
    road.source.roads.push road
    road.target.inRoads.push road
    road.update()

  getRoad: (id) ->
    @roads.get id

  addCar: (car) ->
    @cars.put car

  getCar: (id) ->
    @cars.get(id)

  removeCar: (car) ->
    @cars.pop car

  addIntersection: (intersection) ->
    @intersections.put intersection

  getIntersection: (id) ->
    @intersections.get id

  addRandomCar: ->
    road = _.sample @roads.all()
    if road?
      lane = _.sample road.lanes
      @addCar new Car lane if lane?

  removeRandomCar: ->
    car = _.sample @cars.all()
    if car?
      @removeCar car

module.exports = World
