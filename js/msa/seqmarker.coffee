define ["./utils", "./selection/main"],(Utils, selection) ->
  class SeqMarker

    constructor: (@msa) ->
      @_seqMarkerLayer = document.createElement "div"
      @_seqMarkerLayer.className = "biojs_msa_marker"

    draw: ->
      Utils.removeAllChilds @_seqMarkerLayer

      unless @msa.config.visibleElements.ruler
        return undefined
      else

        # check for offset
        unless @msa.config.visibleElements.labels
          @_seqMarkerLayer.style.paddingLeft = "0px"
        else
          @_seqMarkerLayer.style.paddingLeft = "#{@msa.zoomer.seqOffset}px"

        spacePerCell = @columnHeight + @columnSpacing

        # using fragments is the fastest way
        # try to minimize DOM updates as much as possible
        # http://jsperf.com/innerhtml-vs-createelement-test/6
        residueGroup = document.createDocumentFragment()
        stepSize = @msa.zoomer.getStepSize()
        n = 0

        nMax = @msa.zoomer.len
        if nMax is 0
          nMax = @msa.zoomer.getMaxLength

        while n < nMax
          residueSpan = document.createElement("span")
          residueSpan.textContent = n
          residueSpan.style.width = @msa.zoomer.columnWidth * stepSize + "px"
          residueSpan.style.display = "inline-block"
          residueSpan.rowPos = n
          residueSpan.stepPos = n / stepSize

          residueSpan.addEventListener "click", (evt) =>
            console.log "hi there"
            @msa.selmanager.handleSel new selection.VerticalSelection(@msa,
              evt.target.rowPos, evt.target.stepPos), evt
          , false

          if @msa.config.registerMoveOvers
            residueSpan.addEventListener "mouseover", ((evt) =>
              @msa.selmanager.changeSel new selection.VerticalSelection(@msa,
                evt.target.rowPos, evt.target.stepPos), evt
            ), false

          # color it nicely
          @msa.colorscheme.colorColumn residueSpan, n
          residueGroup.appendChild residueSpan
          n += stepSize

        @_seqMarkerLayer.appendChild residueGroup
        return @_seqMarkerLayer