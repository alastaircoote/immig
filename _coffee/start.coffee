requirejs.config
    shim:
        "d3":
            exports: "d3"
    paths:
        "d3":"//d3js.org/d3.v3.min"

require ["d3","vis/major-categories"], (d3, MajorCategories) ->
    new MajorCategories d3.select("#major-categories")