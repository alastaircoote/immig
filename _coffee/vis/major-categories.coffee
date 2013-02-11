define ["d3"], (d3) ->
    class MajorCategories
        constructor: (@el) ->
            @size = @el
            @el.style "height", window.innerHeight
            @elHeight = window.innerHeight

            extra = Math.round((window.innerWidth - 964) / 2) + 30
            if extra < 0 then extra = 0
            @svg = @el.append("svg")
                .attr("width", 564 + extra)
                .attr("height", @elHeight)
            @loadData()
        loadData: () =>
            d3.json "data/majors.json", (err, json) =>
                if err then throw err
                diameter = 10

                json = json.map (a,i) =>
                    obj = {name:a.name, value: a.value,radius: a.value/300, x:200,y:200 * i}
                    if obj.value == 86519
                      obj.fixed = true
                      obj.x = 664
                      obj.y = @elHeight / 2
                    return obj
                tick = () ->
                    node.attr("transform", (d) ->  "translate(" + d.x + "," + d.y + ")" );

                linksArr = []
                [1...json.length].forEach (i) ->
                  linksArr.push {source:0,target:i}
                  #if i > 1
                    #linksArr.push {source:i, target: i-1}

                force = d3.layout.force()
                    .size([564,@elHeight])
                    .on("tick",tick)
                    .linkDistance((d) -> console.log(d); return 350)
                    .links(linksArr)
                    .charge((d) -> 
                      if d.value == 86519 then -(d.radius * 2) else -((Math.pow(d.radius,2))))
                    .nodes(json)


                node = @svg.selectAll(".node").data(force.nodes());

                force.start()
                [0..50].map (d) ->
                  force.tick()
                #force.stop()
                

                node.enter().append("g")
                  .attr("class", "node")


                node.append("circle")
                  .attr("r", (d) -> console.log(d);return d.radius)
                  .style("fill","#ffffff")
                  #.attr("transform", (d) ->  "translate(" + 250 + "," + 250 + ")" );

                node.append("text")
                  .attr("class","label")
                  .attr("dy", (d) -> if d.radius < 20 then 5 else 0)
                  .attr("dx", (d) -> 0-(d.radius + 10))
                  .style("text-anchor", "end")
                  #.attr("transform","rotate(-10 20,0)")
                  .text((d) -> return d.name );

                node.append("text")
                  .attr("class","value")
                  .style("text-anchor", "middle")
                  .style("font-size", (d) -> d.radius / 1.5 + "px")
                  .attr("dy", (d) -> d.radius / 4)
                  #.attr("transform","rotate(-20 20,0)")
                  .text((d) -> return (Math.round(d.value / 100) / 10) + "k" );

                return
