define ["d3"], (d3) ->
    class MajorCategories
        constructor: (@el) ->
            @size = @el
            @el.style "height", window.innerHeight
            @elHeight = window.innerHeight 

            extra = Math.round((window.innerWidth - 964) / 2) + 30
            if extra < 0 then extra = 0
            @svg = @el.append("svg")
                .attr("width", 1500)
                .attr("height", 650)
            @loadData @draw
            window.addEventListener "scroll", @scroll
        loadData: (cb) =>
            d3.json "data/majors.json", (err, json) =>
                if err then throw err
              
                json.forEach (a,i) =>
                    a.radius = a.value/300
              
                @data = json
                cb()

        draw: () =>

            first = @data.splice(0,1)[0]
            console.log first
            bigOne = @svg
                .append("g")
                .attr("class","major")
                .attr("transform","translate(#{first.x},#{first.y})")

            bigOne.append("circle")
                .attr("r", first.radius)

            bigOne.append("text")
                .attr("class","value")
                .style("font-size", "70px")
                .style("text-anchor", "start")
                .attr("dx",-260)
                .attr("dy", -10)
                .text(@roundValue(first.value))

            @bigLabel = bigOne.append("text")
                .attr("class","label")
                .attr("dx",-245)
                .attr("dy",10)
            
            @bigLabel.append("tspan").text("Computer And")
            @bigLabel.append("tspan").text("Mathematical")
            .attr("dy","1em")
            .attr("dx",-104)


            groups = @svg.selectAll(".major")
              .data(@data)
              .enter()
                .append("g")
                  .attr("class","major")
                  .attr("transform",(d) -> "translate(#{d.x},#{d.y})")
          
            @circles = groups.append("circle")
              .attr("r", (d) -> d.radius)
              
            @nameLabels = groups.append("text")
                .attr("class","label")
                .attr("dy", (d) -> if d.radius < 20 then 5 else 0)
                .attr("dx", (d) -> 0-(d.radius + 10))
                .style("text-anchor", "end")
                .attr("width",200)
                
                
                .each (d,i) ->
                    if i != 3 then return d3.select(this).text(d.name)

                    txt = d3.select(this)
                    txt.append("tspan")
                        .text("Healthcare Practitioners")
                        .attr("dx",0-(d.radius + 10))
                        .attr("dy",-5)
                        .style("text-anchor","end")
                    txt.append("tspan")
                        .text("and Technical")
                        .attr("dy",15)
                        .attr("dx",-100)

            @valueLabels = groups.append("text")
              .attr("class","value")
              .style("font-size", (d) -> d.radius / 1.5 + "px")
              .attr("dy", (d) -> d.radius / 4)
              .text((d) => @roundValue(d.value));

        roundValue: (value) ->
            (Math.round(value / 100) / 10) + "k"

        scroll: (e) =>
            rotateY = 220
            newY = document.body.scrollTop - 100


            ratio = (newY) / rotateY
            if ratio < 0 then ratio = 0

            @nameLabels.style("opacity",ratio)
            @bigLabel.style("opacity",ratio)

            ###
            rotate = 180 - (180 * (newY / rotateY))
            if rotate < 0 then rotate = 0
            console.log "rotate(" + rotate + "deg)"
            console.log @svg
            @svg.style("-webkit-transform", "rotate(" + (rotate) + "deg)")

            targetIndividualRotate = 360 * 3 # 5 spins

            step = targetIndividualRotate - (targetIndividualRotate * (newY / rotateY))
            if step < 0 then step = 0

            @valueLabels.attr("transform","rotate(" + step + ")")
            ###

