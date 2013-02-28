define ["d3"], (d3) ->
    class MajorCategories
        constructor: (@el) ->
            @svg = d3.select(@el[0]).append("svg")
                #.attr("width", 1500)
                #.attr("height", 650)
            @loaded = false
            @showOnLoad = false
            @onResize()
            @loadData @draw

            $(window).on "resize", @onResize

        loadData: (cb) =>
            d3.json "data/majors.json", (err, json) =>
                if err then throw err

                json.forEach (a,i) =>
                    a.radius = Math.sqrt(a.value) / 2 #a.value/300
                    a.x = @sourcePoint.x + (Math.random() * 60)
                    a.sourceX = a.x
                    a.sourceY = @sourcePoint.y - $(window).height() - (Math.random() * 60)
                    delete a.y


                @data = json
                @loaded = true
                cb()
                if @showOnLoad then @show()

        draw: () =>

            @force = d3.layout.force()
              .size([600,$(window).height()])
              .on("tick",@tick)
              #.on("tick", (e) =>
              #  @groups.attr "transform", (d) -> "translate(" +  d.x + "," + d.y + ")")
              .nodes(@data)
              .charge((d) -> -Math.pow(d.radius, 2.0) / 6)
              #.gravity(0)


            self = this
            @baseG = @svg.append("g").attr("id","major-categories")
            @setPosition()
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
                    self.createOverLabel(d,g)

            @hide()

        createCircle: (d, g) =>
            g.append("circle")
                .attr("r", d.radius)
            g.on "mouseover", (e) =>

                    # Ugly hack alert! Bring to front.
                    @baseG[0][0].appendChild(g[0][0])
                    
                    g.attr("class", "major hover")
            g.on "mouseout", (e) =>
                    g.attr("class","major")

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
                    .attr("dy", (d) -> -(d.radius / 6))

        createNameLabel: (d,g) =>
            text = g.append("text")
                .attr("class","label")
                .style("font-size", (d) -> d.radius / 6 + "px")
                .attr("dy", (d) -> d.radius / 6)

            wordSplit = d.name.split(" ")
            for word in wordSplit
                tspan = text.append("tspan")
                    .text(word + " ")
                if text[0][0].offsetWidth > d.radius * 1.5
                    tspan.attr("dy", "1em")
                    tspan.attr("x", 0)

        createOverLabel: (d,g) =>

            rect = g.append("rect")
                .attr("class","overlabel")
                .attr("rx", 7)
                .attr("ry", 7)
                .attr("y", -(d.radius + 25))
                .attr("height", 20)

            text = g.append("text")
                .attr("class","overlabel")
                .text(d.name + " - " + @roundValue(d.value))
                .attr("y", -(d.radius + 10))
            
            rectWidth = text[0][0].getComputedTextLength() + 28

            rect
                .attr("width",rectWidth)
                .attr("x", -(rectWidth / 2))

            text
                .attr("x", -((rectWidth / 2)) + 14)

            console.log(text[0][0].getComputedTextLength())

        show: (t) =>
            if !@loaded then return @showOnLoad = true
            if @currentTransition == "show" then return
            else @currentTransition = "show"
            return @force.start()
        hide: (t) =>
            if t == "up" then @currentTransition = "hide-up"
            else @currentTransition = "hide"
            @force.start()

        roundValue: (value) ->
            (Math.round(value / 100) / 10) + "k"


        tick: (e) =>

            if @currentTransition == "hide"
                @groups.each (d,i) =>
                    d.x = d.x + ( d.sourceX - d.x) * e.alpha * 1.1
            
            else if @currentTransition == "hide-up"
                @groups.each (d,i) =>
                    d.y = d.y + ( d.sourceY - d.y) * e.alpha * 1.1

            else if @currentTransition == "show-down"
                @groups.each (d,i) =>
                    #d.y = d.y + ( d.sourceY - d.y) * e.alpha * 1.1

            @groups.attr "transform", (d) -> "translate(" +  d.x + "," + d.y + ")"
        onResize: () =>
            y = 20
            middle = @el.width() / 2
            rightSide = middle + 512 # #content is 1024px wide
            x = rightSide - 610 # Figure I just came up with
            @setPosition(x,null)

            #if @baseG then @baseG.attr("transform","translate(#{x},#{y})")
            #console.log $(window).height() / 2
            @sourcePoint =
                x: $(window).width() + 100
                y: ($(window).height() / 2)

        setPosition: (newLeft, newTop) =>
            @left = newLeft || @left || 0
            @top = newTop || @top || 0
            if @baseG then @baseG.attr("transform", "translate(#{@left},#{@top})")

