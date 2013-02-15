requirejs.config
    shim:
        "d3":
            exports: "d3"
    paths:
        "d3":"//d3js.org/d3.v3.min"
        "jquery": "//code.jquery.com/jquery-1.9.1.min"

require ["d3","vis/major-categories", "jquery"], (d3, MajorCategories, $) ->
    majors = new MajorCategories $("#svg-holder")

    fixedTop = parseInt($("#svg-holder").css("top"),10)


    lastScrollBottom = 0

    $(window).on "scroll", () ->
        if $(window).scrollTop() >= fixedTop
            $("#svg-holder").addClass("fixed")
        else
            $("#svg-holder").removeClass("fixed")


        scrollBottom = $(window).height() + $(window).scrollTop()
        console.log scrollBottom
        if scrollBottom >= 800 && lastScrollBottom < 800
            majors.show()
        else if scrollBottom < 800 && lastScrollBottom >= 800
            majors.hide("up")


        lastScrollBottom = scrollBottom

    $(window).trigger("scroll")

