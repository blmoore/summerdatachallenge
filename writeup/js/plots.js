var ctx = $("#myChart").get(0).getContext("2d");

var data = {
    labels: ["Jan 09", "Feb 09", "Mar 09", "Apr 09", "May 09", "Jun 09", "Jul 09", "Aug 09", "Sep 09", "Oct 09", "Nov 09", "Dec 09",
    "Jan 10", "Feb 10", "Mar 10", "Apr 10", "May 10", "Jun 10", "Jul 10", "Aug 10", "Sep 10", "Oct 10", "Nov 10", "Dec 10",
    "Jan 11", "Feb 11", "Mar 11", "Apr 11", "May 11", "Jun 11", "Jul 11", "Aug 11", "Sep 11", "Oct 11", "Nov 11", "Dec 11",
    "Jan 12", "Feb 12", "Mar 12", "Apr 12", "May 12", "Jun 12", "Jul 12", "Aug 12", "Sep 12", "Oct 12", "Nov 12", "Dec 12",
    "Jan 13", "Feb 13", "Mar 13", "Apr 13", "May 13", "Jun 13", "Jul 13", "Aug 13", "Sep 13", "Oct 13", "Nov 13", "Dec 13",
    "Jan 14", "Feb 14", "Mar 14", "Apr 14", "May 14"],
    datasets: [
    // First dataset: SW18
        {
            label: "SW18",
            fillColor: "rgba(151,187,205,0.2)",
            strokeColor: "rgba(151,187,205,.2)",
            pointColor: "rgba(151,187,205,1)",
            pointStrokeColor: "#fff",
            pointHighlightFill: "#fff",
            pointHighlightStroke: "rgba(220,220,220,1)",
            data: [399000, 409000, 417000, 426000, 435000, 443000, 450000,
            458000, 465000, 471000, 477000, 483000, 488000, 493000, 496000,
            500000, 504000, 507000, 510000, 513000, 515000, 516000, 517000,
            516000, 516000, 515000, 514000, 513000, 513000, 514000, 514000,
            515000, 515000, 515000, 516000, 516000, 518000, 519000, 521000,
            524000, 526000, 529000, 532000, 536000, 539000, 542000, 546000,
            550000, 554000, 558000, 562000, 567000, 572000, 577000, 582000,
            588000, 594000, 600000, 607000, 613000, 620000, 627000, 634000,
            641000, 649000]
        },
        {
            label: "All",
fillColor: "rgba(220,220,220,0.2)",
strokeColor: "rgba(220,220,220,1)",
pointColor: "rgba(220,220,220,1)",
            pointStrokeColor: "#fff",
            pointHighlightFill: "#fff",
            pointHighlightStroke: "rgba(151,187,205,1)",
            data: [266000, 271000, 275000, 279000, 283000, 287000, 291000,
            295000, 298000, 302000, 305000, 308000, 310000, 313000, 315000,
            317000, 319000, 321000, 323000, 325000, 326000, 327000, 328000,
            328000, 329000, 329000, 330000, 330000, 330000, 330000, 330000,
            329000, 329000, 328000, 328000, 329000, 329000, 330000, 330000,
            331000, 332000, 333000, 334000, 334000, 335000, 336000, 337000,
            339000, 340000, 341000, 342000, 343000, 344000, 345000, 346000,
            347000, 349000, 350000, 351000, 352000, 353000, 354000, 356000,
            357000, 358000]
        }
    ]
};

var myNewChart = new Chart(ctx);

Chart.defaults.global = {
    // Boolean - Whether to animate the chart
    animation: true,

    // Number - Number of animation steps
    animationSteps: 60,

    // String - Animation easing effect
    animationEasing: "easeOutQuart",

    // Boolean - If we should show the scale at all
    showScale: true,

    // Boolean - If we want to override with a hard coded scale
    scaleOverride: false,

    // ** Required if scaleOverride is true **
    // Number - The number of steps in a hard coded scale
    scaleSteps: null,
    // Number - The value jump in the hard coded scale
    scaleStepWidth: null,
    // Number - The scale starting value
    scaleStartValue: null,

    // String - Colour of the scale line
    scaleLineColor: "rgba(0,0,0,.1)",

    // Number - Pixel width of the scale line
    scaleLineWidth: 1,

    // Boolean - Whether to show labels on the scale
    scaleShowLabels: true,

    // Interpolated JS string - can access value
    scaleLabel: "<%=value%>",

    // Boolean - Whether the scale should stick to integers, not floats even if drawing space is there
    scaleIntegersOnly: true,

    // Boolean - Whether the scale should start at zero, or an order of magnitude down from the lowest value
    scaleBeginAtZero: false,

    // String - Scale label font declaration for the scale label
    scaleFontFamily: "'Helvetica Neue', 'Helvetica', 'Arial', sans-serif",

    // Number - Scale label font size in pixels
    scaleFontSize: 12,

    // String - Scale label font weight style
    scaleFontStyle: "normal",

    // String - Scale label font colour
    scaleFontColor: "#666",

    // Boolean - whether or not the chart should be responsive and resize when the browser does.
    responsive: true,

    // Boolean - whether to maintain the starting aspect ratio or not when responsive, if set to false, will take up entire container
    maintainAspectRatio: true,

    // Boolean - Determines whether to draw tooltips on the canvas or not
    showTooltips: true,

    // Array - Array of string names to attach tooltip events
    tooltipEvents: ["mousemove", "touchstart", "touchmove"],

    // String - Tooltip background colour
    tooltipFillColor: "rgba(0,0,0,0.8)",

    // String - Tooltip label font declaration for the scale label
    tooltipFontFamily: "'Helvetica Neue', 'Helvetica', 'Arial', sans-serif",

    // Number - Tooltip label font size in pixels
    tooltipFontSize: 14,

    // String - Tooltip font weight style
    tooltipFontStyle: "normal",

    // String - Tooltip label font colour
    tooltipFontColor: "#fff",

    // String - Tooltip title font declaration for the scale label
    tooltipTitleFontFamily: "'Helvetica Neue', 'Helvetica', 'Arial', sans-serif",

    // Number - Tooltip title font size in pixels
    tooltipTitleFontSize: 14,

    // String - Tooltip title font weight style
    tooltipTitleFontStyle: "bold",

    // String - Tooltip title font colour
    tooltipTitleFontColor: "#fff",

    // Number - pixel width of padding around tooltip text
    tooltipYPadding: 6,

    // Number - pixel width of padding around tooltip text
    tooltipXPadding: 6,

    // Number - Size of the caret on the tooltip
    tooltipCaretSize: 8,

    // Number - Pixel radius of the tooltip border
    tooltipCornerRadius: 6,

    // Number - Pixel offset from point x to tooltip edge
    tooltipXOffset: 10,

    // String - Template string for single tooltips
    tooltipTemplate: "<%if (label){%><%=label%>: <%}%><%= value %>",

    // String - Template string for single tooltips
    multiTooltipTemplate: "<%= value %>",

    // Function - Will fire on animation progression.
    onAnimationProgress: function(){},

    // Function - Will fire on animation completion.
    onAnimationComplete: function(){}
}


var myLineChart = new Chart(ctx).Line(data, {

    ///Boolean - Whether grid lines are shown across the chart
    scaleShowGridLines : false,

    //String - Colour of the grid lines
    scaleGridLineColor : "rgba(0,0,0,.05)",

    //Number - Width of the grid lines
    scaleGridLineWidth : 1,

    //Boolean - Whether the line is curved between points
    bezierCurve : true,

    //Number - Tension of the bezier curve between points
    bezierCurveTension : 0.4,

    //Boolean - Whether to show a dot for each point
    pointDot : true,

    //Number - Radius of each point dot in pixels
    pointDotRadius : 4,

    //Number - Pixel width of point dot stroke
    pointDotStrokeWidth : 1,

    //Number - amount extra to add to the radius to cater for hit detection outside the drawn point
    pointHitDetectionRadius : 1,

    //Boolean - Whether to show a stroke for datasets
    datasetStroke : true,

    //Number - Pixel width of dataset stroke
    datasetStrokeWidth : 2,

    //Boolean - Whether to fill the dataset with a colour
    datasetFill : true,

    //String - A legend template
    legendTemplate : "<ul class=\"<%=name.toLowerCase()%>-legend\"><% for (var i=0; i<datasets.length; i++){%><li><span style=\"background-color:<%=datasets[i].lineColor%>\"></span><%if(datasets[i].label){%><%=datasets[i].label%><%}%></li><%}%></ul>"

});
