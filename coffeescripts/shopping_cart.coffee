#
# models and collections: nothing very exciting here
#
LineItem = Backbone.Model.extend({})
LineItemList = Backbone.Collection.extend({})
Service = Backbone.Model.extend({})
ServiceRequest = Backbone.Model.extend
  initialize: ->
    @line_items = new LineItemList()


#
# The service view listens for its own click and as defined in the events map,
# will dispatch its own report_id function when the click even happens.
# report_id does a manual trigger of the custom foo event, which is bound the view
# at the instantiation of the view object from within the CatalogView.
#
# The cool thing here is that trigger will happily accept arguments, 
# like here the id of the service, so that whatever watcher for this event will be privy
# to the specifics of the event.
#
ServiceView = Backbone.View.extend
  initialize: -> $(@el).text @model.get('name')
  events: {"click" : "report_id"}
  tagName: "h4"
  report_id: -> @trigger("foo", @model.get('id'))

#
# The cart view will be used to display the items in the service request's 
# line items. It will do this not by direct notification, but by watching
# the collections' add event
# 
CartView = Backbone.View.extend
  tagName: "ul"

  initialize: ->
    _.bindAll @, "render", "add_to_cart"
    @collection = @model.line_items
    # here is where we watch
    @collection.bind("add", @add_to_cart)
    $(@el).append("<h1>My Cart</h1>") # => not using templates, ignore the ugliness
         
  add_to_cart: (li)->
    name = svs[li.get('service_id')].get('name')
    $(@el).append("<li>#{name}</li>")

#
# CatalogView is the master view, it creates the child views and sets up the
# glue code needed to coordinate the views.
# For this example it also does all the work making some pretend services, etc.
#
# The magic happens by binding each service view with an even called 'foo'
# It then becomes the responsibility of the service view to dispatch that function such that
# the CatalogView gets notified. -- See the ServiceView code --
# 
# This also means that each service view doesn't need to know about the service request, 
# it can just know about its own service id. The CatalogView will take care of creating
# and adding the line item to the service request
#
CatalogView = Backbone.View.extend
  
  initialize: (atts)-> 
    _.bindAll @, "hello_service"
    $(@el).append("<h1>My Services</h1>") # => not using templates, ignore the ugliness
    for s, i in atts.services
      view = new ServiceView({model:s})
      view.bind('foo', @hello_service) #=> now it can report back
      $(@el).append(view.render().el)
      
    @cart = new CartView({model: @model})
    $(@el).append(@cart.render().el)

  hello_service: (id)->
    li = new LineItem(service_id: id)
    @model.line_items.add(li)
      
#
# prepare the data: 
# this is just marching through the details to display something
#
svs = []
names = ["joe", "bob"]
for n,i in names
  svs.push(new Service(name:n, id:i))

sr = new ServiceRequest()
Catalog = new CatalogView({model: sr, services: svs})

# render to body
# wrapping in a jquery ready function
$ ->
  $("body").html(Catalog.render().el)

