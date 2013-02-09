define ["d3"], (d3) ->
    class MajorCategories
        constructor: (@el) ->
            @svg = @el.append("svg")
                .attr("width", 600)
                .attr("height", 500)
            @loadData()
        loadData: () =>
            d3.json "data/minors.json", (err, json) =>
                if err then throw err
                diameter = 10

                json = json.map (a)->
                    return {name:a.name, value: a.value,radius: a.value/400, x:250, y:250}

                tick = () ->
                    node.attr("transform", (d) ->  "translate(" + d.x + "," + d.y + ")" );


                force = d3.layout.force()
                    .size([500,500])
                    .on("tick",tick)
                    #.linkDistance((d) -> return 0 - (d.value/30))
                    #.links([0...json.length].map (i) -> return {source:0, target:i})
                    .charge((d) -> -Math.pow(d.radius, 2.0) / 5)
                    .nodes(json)

                force.start()
                node = @svg.selectAll(".node").data(force.nodes());

                node.enter().append("g")
                  .attr("class", "node")


                node.append("circle")
                  .attr("r", (d) -> console.log(d);return d.radius)
                  #.attr("transform", (d) ->  "translate(" + 250 + "," + 250 + ")" );

                return

                bubble = d3.layout.pack()
                    .sort((a,b) -> return a.name - b.name)
                    .size([600, 500])
                    .padding(1.5);

                node = @svg.selectAll(".node")
                  .data(bubble.nodes({children:json})
                  .filter((d) -> return !d.children))
                .enter().append("g")
                  .attr("class", "node")
                  .attr("transform", (d) -> console.log(d); return "translate(" + d.x + "," + d.y + ")")

                node.append("circle")
                  .attr("r", (d) -> return d.r)
                  #.style("fill", function(d) { return color(d.packageName); });

                node.append("text")
                  .attr("dy", ".3em")
                  .style("text-anchor", "middle")
                  .text((d) -> return d.name );