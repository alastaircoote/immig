define ["d3"], (d3) ->
    class MajorCategories
        constructor: (@el) ->
            @svg = d3.select(@el[0]).append("svg")
                #.attr("width", 1500)
                #.attr("height", 650)
            @loaded = false
            @showOnLoad = false
            @loadData @draw
            #window.addEventListener "scroll", @scroll

        loadData: (cb) =>
            d3.json "data/majors.json", (err, json) =>
                if err then throw err

                json.forEach (a,i) =>
                    a.radius = Math.sqrt(a.value) / 2 #a.value/300
                    a.targetX = a.x
                    a.targetY = a.y

                    if a.isBig
                        a.sourceX = a.x + 500
                        a.sourceY = a.y
                        return

                    a.sourceX = a.x - (Math.random() * 600)

                    if a.y < 312
                        a.sourceY = a.y - (Math.random() * 600)
                    else
                        a.sourceY = a.y + (Math.random() * 600)

                @data = json
                @loaded = true
                cb()
                if @showOnLoad then @show()

        draw: () =>

            @force = d3.layout.force()
              .size([500,400])
              #.on("tick",@tick)
              .on("tick", (e) =>
                @groups.attr "transform", (d) -> "translate(" +  d.x + "," + d.y + ")")
              .nodes(@data)
              .charge((d) -> -Math.pow(d.radius, 2.0) / 6)
              #.gravity(0)


            self = this
            @baseG = @svg.append("g").attr("id","major-categories")
            @onResize()

            @groups = @baseG.selectAll(".major")
                .data(@data)
                .enter()
                .append("g")
                .each (d) ->

                    g = d3.select(this)
                    g.attr("class","major")
                    g.attr("transform",(d) -> "translate(#{d.x},#{d.y})")
                    self.createCircle(d,g)
                    self.createValueLabel(d,g)
                    self.createNameLabel(d,g)

        createCircle: (d, g) =>
            g.append("circle").attr("r", d.radius)

        createValueLabel: (d,g) =>
            text = g.append("text")
                .attr("class","value")
                .text((d) => @roundValue(d.value))

            if d.isBig && 1==2
                text.style("font-size", "70px")
                    .style("text-anchor", "start")
                    .attr("dx",-260)
                    .attr("dy", -10)
            else
                text.style("font-size", (d) -> d.radius / 2 + "px")
                    .attr("dy", (d) -> d.radius / 4)

        createNameLabel: (d,g) =>
            text = g.append("text")
                .attr("class","label")





            #
            if d.isBig
                text.attr("dx",-140)
                    .attr("dy",10)
                text.append("tspan").text("Computer And")
                text.append("tspan").text("Mathematical")
                    .attr("dy","1em")
                    .attr("dx",-104)
                return

            if d.name == "Healthcare Practitioners and Technical"
                text.append("tspan")
                        .text("Healthcare Practitioners")
                        .attr("dx",0-(d.radius + 10))
                        .attr("dy",-5)
                        .style("text-anchor","end")
                text.append("tspan")
                    .text("and Technical")
                    .attr("dy",15)
                    .attr("dx",-100)
            else
                text.attr("dy", (d) -> if d.radius < 20 then 5 else 0)
                .attr("dx", (d) -> 0-(d.radius + 10))
                .text((d) => d.name)

        show: () =>

            if !@loaded then return @showOnLoad = true
            @baseG.attr("class","visible")
            return @force.start()
            @currentTransition = "show"
            @data.forEach (d) ->
                d.currentTargetX = d.targetX
                d.currentTargetY = d.targetY
                d.x = d.sourceX
                d.y = d.sourceY
            

            @force.start()

        hide: () =>
            @currentTransition = "hide"
            @data.forEach (d) ->
                d.currentTargetX = d.sourceX
                d.currentTargetY = d.sourceY
                d.x = d.targetX
                d.y = d.targetY

            @force.start()

        roundValue: (value) ->
            (Math.round(value / 100) / 10) + "k"


        tick: (e) =>
            @groups.each (d) =>
                targetY = 100
                targetX = 300
                d.x = d.x + (d.currentTargetX - d.x) * e.alpha * 1.1
                d.y = d.y + (d.currentTargetY - d.y) * e.alpha * 1.1

            @groups.attr "transform", (d) -> "translate(" +  d.x + "," + d.y + ")"
            @groups.style "opacity", (d) =>
                if @currentTransition == "show" then d.x / d.currentTargetX
                else 0.7-(d.x / d.currentTargetX)

            if e.alpha < 0.05
                if @currentTransition == "show" then @baseG.attr("class", "visible visible-label")
                else @baseG.attr("class", "visible")

        onResize: () =>
            y = 20
            middle = @el.width() / 2
            rightSide = middle + 512 # #content is 1024px wide
            x = rightSide - 610 # Figure I just came up with

            @baseG.attr("transform","translate(#{x},#{y})")

