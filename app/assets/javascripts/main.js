const pointsHeader = [['Measurements', 'Signal']];
var points = [];
// var dummyPoints = [ 100, 500, 300];

const successClass = "alert alert-success";
const failedClass = "alert alert-danger";

const successContent = "YES";
const failedContent = "NO";

var tid;
var limit = 20;

// initPoints();

var offset = 0;
var error = false;

// var server = "http://127.0.0.1:3000";
var server = "https://sittingsensor.herokuapp.com";

// Call to start timer and initialise points for chart
function initPoints() {
  google.charts.load('current', {'packages':['corechart']});
  google.charts.setOnLoadCallback(drawChart);

  updatePoints();

  tid = setInterval(updateState, 1000);
}

// Update the state of the site, draw new chart and check if person is seated
function updateState() {

  var isSeated = updatePoints();

  // var lastSignal = points.length - 1;
  // var isSeated = points[lastSignal][1] > 250;
  if (!error) {
    drawResult(isSeated);
  }
}

// Updates points with new ones from the DB
function updatePoints() {
  var result = $.parseJSON(fetchPoints(limit));

  if (!error) {
    offset = offset + 1;

    var allPoints = result["values"];
    var isSeated = result["result"];

    // === Hack so you can see how the interface works ===
    // var newPoint = Math.floor(Math.random() * 500) + 50;
    // dummyPoints.push(newPoint);
    // allPoints = dummyPoints;
    // === End of hack ===

    // allPoints.unshift()
    points = pointsHeader;
    for (var i in allPoints) {
      addPoint(allPoints[i]);
    }

    return isSeated
  }
}

// Fetch data from DB to get new points / info
function fetchPoints(limit) {  
  return $.ajax({
    method: "GET",
    url: (server + "/get_last_values"),
    dataType: "json",
    async: false,
    data: {limit: limit, offset: offset},
    error: function(xhr, textStatus, errorThrown){
      clearInterval(tid);
      error = true;
      if(xhr.status == 500) {
        window.location.replace(server + "/error");
      } else if(xhr.status == 400) {
        window.location.replace(server + "/calibration");
      }
    }
  }).responseText;
}

// Draw chart
function drawChart() {
  var data = google.visualization.arrayToDataTable(points);

  var options = {
    title: 'RSSI Signal',
    curveType: 'function',
    animation: {"startup": true},
    legend: { position: 'bottom' },
    'vAxis': {'title': '',
               'minValue': -85, 
               'maxValue': -35},
  };

  chart = new google.visualization.LineChart(document.getElementById('curve_chart'));

  chart.draw(data, options);
}


// Draws chart and if the person is seated or not
function drawResult(isSeated) {
  var div = document.getElementById("seated");
  div.classList.value = isSeated ? successClass : failedClass;
  div.textContent = isSeated ? successContent : failedContent;

  drawChart();
}


// Add point to points list
function addPoint(y) {
  var index = points.length;
  points = points.concat([[index, y]]);
}

// If for some reason you want to stop the interval
function abortTimer() {
  clearInterval(tid);
}