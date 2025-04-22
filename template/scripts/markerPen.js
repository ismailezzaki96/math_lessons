(function ($) {
  $.extend({
    markerPen: function (options) {
      // Default settings
      var options = {
        color: "red",
        stroke: 10,
        opacity: 0.7,
      };

      // Variables
      var lastX, lastY, ctx;
      var isDrawing = false;
      var isEnabled = true;
      var isHidden = false;
      var areControlsHidden = false;

      // Create UI elements
      $("body").append(`
                <div id="marker_pen_main">
                    <canvas id="markerPenCanvas"></canvas>
                </div>
                <div id="marker_pen_controls">
                    <a id="togglebtn" style="display:none">Disable</a>
                    <a id="clearbtn">Clear</a>
                </div>
                <div id="marker_pen_hide_control">
                    <a id="hidecontrols"><</a>
                </div>
            `);

      // Style UI elements

      $("#marker_pen_main").css({
        position: "absolute",
        top: "0%",
        left: "0%",
      });

      $("#marker_pen_controls").css({
        width: "100%",
        position: "fixed",
        bottom: "0",
        "background-color": "rgb(51,51,51)",
        color: "rgb(255,255,255)",
        "padding-left": "4%",
        left: 0,
      });

      $("#marker_pen_hide_control").css({
        position: "fixed",
        bottom: "0",
        "background-color": "rgb(51,51,51)",
        color: "rgb(255,255,255)",
        left: 0,
      });

      $("#marker_pen_controls a").css({
        "padding-left": "2%",
        "padding-right": "2%",
        "margin-left": "1%",
      });

      $("#markerPenCanvas").css({
        opacity: options.opacity,
      });

      $("#hidebtn").css({
        opacity: "0.2",
        "pointer-events": "none",
      });

      $("#marker_pen_svg").css({
        position: "absolute",
      });

      // Set up canvas
      ctx = document.getElementById("markerPenCanvas").getContext("2d");
      ctx.canvas.height = $(document).height() + $("#marker_pen_main").height();
      ctx.canvas.width = $(document).width();

      // Highlight the default tool (marker)

      // Helper function to draw or erase
      function drawLine(x, y, shouldDraw) {
        if (shouldDraw) {
          ctx.beginPath();
          ctx.globalCompositeOperation = "source-over";
          ctx.strokeStyle = options.color;
          ctx.lineWidth = options.stroke;
          ctx.lineJoin = "round";
          ctx.moveTo(lastX, lastY);
          ctx.lineTo(x, y);
          ctx.closePath();
          ctx.stroke();
        }

        lastX = x;
        lastY = y;
      }

      // Clear the canvas
      function clearCanvas() {
        ctx.setTransform(1, 0, 0, 1, 0, 0);
        ctx.clearRect(0, 0, ctx.canvas.width, ctx.canvas.height);
      }

      // Event: Mouse down on canvas
      $("#markerPenCanvas").mousedown(function (e) {
        isDrawing = true;
        drawLine(
          e.pageX - $(this).offset().left,
          e.pageY - $(this).offset().top,
          false,
        );
      });

      // Event: Mouse move on canvas
      $("#markerPenCanvas").mousemove(function (e) {
        if (isDrawing) {
          drawLine(
            e.pageX - $(this).offset().left,
            e.pageY - $(this).offset().top,
            true,
          );
        }
      });

      // Event: Mouse up on canvas
      $("#markerPenCanvas").mouseup(function () {
        isDrawing = false;
      });

      // Event: Mouse leaves canvas
      $("#markerPenCanvas").mouseleave(function () {
        isDrawing = false;
      });

      // Event: Clear button click
      $("#clearbtn").click(function () {
        clearCanvas();
      });

      // Event: Hide controls button click
      $("#hidecontrols").click(function () {
        if (!areControlsHidden) {
          $("#marker_pen_controls").animate({
            left: "-100%",
          });
          document.getElementById("hidecontrols").innerHTML = ">";
          areControlsHidden = true;
        } else {
          $("#marker_pen_controls").animate({
            left: "0%",
          });
          document.getElementById("hidecontrols").innerHTML = "<";
          areControlsHidden = false;
        }

        // Toggle the tool state
        $("#togglebtn").click();
      });


      // Event: Toggle button click
      $("#togglebtn").click(function () {
        if (isEnabled) {
          isEnabled = false;
          document.getElementById("togglebtn").innerHTML = "Enable markerPen";
          $("#marker_pen_main, #clearbtn").css({
            "pointer-events": "none",
          });
          $("#clearbtn").css({
            opacity: 0.2,
          });
          $("#hidebtn").css({
            opacity: 1,
            "pointer-events": "auto",
          });
        } else {
          isEnabled = true;
          document.getElementById("togglebtn").innerHTML = "Disable markerPen";
          $("#marker_pen_main, #clearbtn").css({
            "pointer-events": "auto",
          });
          $("#clearbtn").css({
            opacity: 1,
          });
          $("#hidebtn").css({
            opacity: 0.2,
            "pointer-events": "none",
          });
          isHidden = false;
          document.getElementById("hidebtn").innerHTML = "Hide Markings";
          $("#marker_pen_main").css({
            display: "block",
          });
        }
      });

      // Event: Hide button click
      $("#hidebtn").click(function () {
        if (isHidden) {
          isHidden = false;
          document.getElementById("hidebtn").innerHTML = "Hide Markings";
          $("#marker_pen_main").css({
            display: "block",
          });
        } else {
          isHidden = true;
          document.getElementById("hidebtn").innerHTML = "Show Markings";
          $("#marker_pen_main").css({
            display: "none",
          });
        }
      });

      // Initialize with controls hidden
      $("#hidecontrols").click();
    },
  });
})(jQuery);
