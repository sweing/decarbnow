import { map, tileLayer, marker, Icon } from 'leaflet';
import twemoji from 'twemoji';
import TwitterWidgetsLoader from 'twitter-widgets';
import $ from 'jquery';
import { encode } from '@alexpavlov/geohash-js';
import MarkerClusterGroup from 'leaflet.markercluster';
import leaflet_sidebar from 'leaflet-sidebar';

//**************************************************************************
// configuration and declaration
//**************************************************************************
var twittermarker;

let decarbnowMap = map('map', {
    zoomControl: false // manually added
}).setView([48.2084, 16.373], 11);

let markerInfo = {
    "climateaction": {
        "img": "/dist/img/action.png",
        "title": "Climate Action",
        "question": "Who took action?",
        "desc": "Some do, some dont. We all want change. See what others do and get inspired!"
    },
    "pollution":  {
        "img": "/dist/img/pollution.png",
        "title": "Pollution",
        "question": "Who pollutes our planet?",
        "desc": "Some do, some dont. We all want change. See who works against positive change!!"
    },
    "transition": {
        "img": "/dist/img/transition.png",
        "title": "Transitions",
        "question": "Who takes the first step?",
        "desc": "Switching to lower energy consuming machinery is the first step. See who is willing to make the first step."
    }
};
let currentMarkers = {};
let currentMarkerFilters = ["climateaction", "pollution", "transition"];

let LeafIcon = Icon.extend({
    options: {
        //shadowUrl: 'dist/img/leaf-shadow.png',
        iconSize:     [32, 32],
        //shadowSize:   [50, 64],
        iconAnchor:   [16, 16],
        //shadowAnchor: [4, 62],
        popupAnchor:  [0, -16]
    }
});

let icons = {
    "climateaction": new LeafIcon({iconUrl: markerInfo.climateaction.img}),
    "pollution": new LeafIcon({iconUrl: markerInfo.pollution.img}),
    "transition": new LeafIcon({iconUrl: markerInfo.transition.img})
};

let showGeoLoc = L.popup().setContent(
    '<p>Tell the World!</p>'
);

let markerClusters = L.markerClusterGroup(
    {
        disableClusteringAtZoom: 19,
        maxClusterRadius: 100,
        animatedAddingMarkers: false,
        showCoverageOnHover: false
        //removeOutsideVisibleBounds: true
    });

let sidebar = L.control.sidebar('sidebar', {
    closeButton: true,
    position: 'left'
});


//**************************************************************************
// functions
//**************************************************************************

function initializeMarkers() {
    currentMarkers = {
        "climateaction": [],
        "pollution": [],
        "transition": []
    };
}

function createBackgroundMap() {
    return tileLayer('https://api.mapbox.com/styles/v1/sweing/cjrt0lzml9igq2smshy46bfe7/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1Ijoic3dlaW5nIiwiYSI6ImNqZ2gyYW50ODA0YTEycXFxYTAyOTZza2IifQ.NbvRDornVZjSg_RCJdE7ig', {
        attribution: '© <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>, © <a href="https://www.mapbox.com/legal/tos/">MapBox</a>'
    });
}

function createBackgroundMapSat() {
    return tileLayer('https://api.mapbox.com/styles/v1/sweing/ck1xo0pmx1oqs1co74wlf0dkn/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1Ijoic3dlaW5nIiwiYSI6ImNqZ2gyYW50ODA0YTEycXFxYTAyOTZza2IifQ.NbvRDornVZjSg_RCJdE7ig', {
        attribution: '© <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>, © <a href="https://www.mapbox.com/legal/tos/">MapBox</a>'
    });
}
//https://api.mapbox.com/styles/v1/sweing/ck1xo0pmx1oqs1co74wlf0dkn/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1Ijoic3dlaW5nIiwiYSI6ImNqZ2gyYW50ODA0YTEycXFxYTAyOTZza2IifQ.NbvRDornVZjSg_RCJdE7ig
//https://api.mapbox.com/styles/v1/sweing/cjrt0lzml9igq2smshy46bfe7/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1Ijoic3dlaW5nIiwiYSI6ImNqZ2gyYW50ODA0YTEycXFxYTAyOTZza2IifQ.NbvRDornVZjSg_RCJdE7ig


function pollutionStyle(feature) {
    return {
        fillColor: "#FF0000",
        stroke: false,
        interactive: false,
        //weight: 2,
        //opacity: 1,
        //color: 'white',
        //dashArray: '3',
        fillOpacity: getPollutionOpacity(feature.properties.value)
    };
}

function getPollutionOpacity(value) {

    //let max = 24009000000000000;
    //let min = 350000000000000;
    let max = 1;
    let min = 0;

    //return Math.max(0, (value - min ) / (max - min) * 0.3);
    return 0.1;
}

function createLayer1() {
    return L.tileLayer(
        'https://api.mapbox.com/styles/v1/sweing/ck1xo0pmx1oqs1co74wlf0dkn/tiles/256/{z}/{x}/{y}@2x?access_token=pk.eyJ1Ijoic3dlaW5nIiwiYSI6ImNqZ2gyYW50ODA0YTEycXFxYTAyOTZza2IifQ.NbvRDornVZjSg_RCJdE7ig', {
        tileSize: 512,
        zoomOffset: -1,
        attribution: '© <a href="https://www.mapbox.com/map-feedback/">Mapbox</a> © <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>'
    });
}

function showError() {
    alert('Please make sure, all blockers are disabled. Otherwise, tweets will not load.');
    /*
    modal(
        { title: 'Disable Blockers'
            , content: 'Please make sure, all blockers are disabled. Otherwise, tweets will not load.'
            , buttons:
                [
                    { text: 'OK', event: 'cancel', keyCodes: [ 13, 27 ] }
//                    , { text: 'Delete', event: 'confirm', className: 'button-danger', iconClassName: 'icon-delete' }
                ]
        });
        //.on('confirm', deleteItem)
    */
}

/*
let videoUrl = 'https://www.mapbox.com/bites/00188/patricia_nasa.webm',
    videoBounds = [[ 32, -130], [ 13, -100]];
L.videoOverlay(videoUrl, videoBounds ).addTo(decarbnowMap);
*/

/*
let videoUrl = 'dist/img/tropomi.mp4',
    videoBounds = [[ 70, -180], [ -70, 180]],
    videoOptions = {opacity: 0.5};
L.videoOverlay(videoUrl, videoBounds, videoOptions).addTo(decarbnowMap);
*/


//console.log(markers);


function refreshMarkers() {
    markerClusters.clearLayers()
    if ($('.decarbnowpopup').length > 0) {
        return;
    }
    $.get('https://decarbnow.space/api/poi', function(data) {
    //$.get('poi.json', function(data) {
        console.log("function refreshMarkers");
        for (var i in currentMarkers) {
            for (var mi in currentMarkers[i]) {
                decarbnowMap.removeLayer(currentMarkers[i][mi]);
            }
        }

        initializeMarkers();
        data._embedded.poi.forEach(function(item) {

            let text = item.message;
            let twitterId = null;
            //"POINT (48.1229059305042 16.5587781183422)"
            let p = item.position
            let bp = p.substring(p.indexOf("(")+1,p.indexOf(")")).split(" ")
            let long = parseFloat(bp[0])
            let lat = parseFloat(bp[1])
            
            if(currentMarkerFilters.indexOf(item.type) === -1){
                return;
            }
            if (item.urlLinkedTweet) {
                let tws = item.urlLinkedTweet.split("/");
                twitterId = tws[tws.length-1];
                text += '<br/><div id="tweet-' + twitterId + '"></div>'; // <a href=\"" + item.origurl + "\"><img src=\"dist/img/twitter.png\" /></a>
            }
            let mm = marker([long, lat], {icon: icons[item.type]});

            //mm.sidebar.setContent(twemoji.parse(text)).show()
            
            //decarbnowMap.addLayer(markerClusters);
            currentMarkers[item.type].push(mm
                
                .addTo(markerClusters)
                .on('click', function () {
                    sidebar.show(); 
                    sidebar.setContent(twemoji.parse(text));
                })
                //.addTo(decarbnowMap)
            );

            //sidebar.setContent(twemoji.parse(text));

            if (item.urlLinkedTweet) {
                mm.on("click", () => {
                    TwitterWidgetsLoader.load(function(err, twttr) {
                        if (err) {
                            showError();
                            return;
                        }

                        twttr.widgets.createTweet(twitterId, document.getElementById('tweet-' + twitterId));
                    });
                });
            }
        });
    });
    
}


L.Control.Markers = L.Control.extend({
    onAdd: function(map) {
        let markerControls = L.DomUtil.create('div');
        markerControls.style.width = '400px';
        markerControls.style.height = '45px';
        markerControls.style.backgroundColor = '#fff';
        markerControls.style.display = 'flex';
        markerControls.style.flexDirection = 'row';
        markerControls.style.justifyContent = 'space-evenly';
        markerControls.style.alignItems = 'center';
        markerControls.style.padding = "3px";
        markerControls.classList.add("leaflet-bar");

        Object.keys(markerInfo).forEach(markerKey => {
            let marker = markerInfo[markerKey];
            let markerContainer = L.DomUtil.create('div');
            markerContainer.innerHTML = '<img src="' + marker.img + '" style="vertical-align:middle" /> ' + marker.title;
            markerContainer.title = marker.question + " " + marker.desc;
            markerControls.append(markerContainer);
        });

        return markerControls;
    },

    onRemove: function(map) {
        // Nothing to do here
    }
});
L.control.markers = function(opts) {
    return new L.Control.Markers(opts);
};

//**************************************************************************
// events
//**************************************************************************
decarbnowMap.on('contextmenu',function(e){

    if (typeof twittermarker !== 'undefined') { // check
        decarbnowMap.removeLayer(twittermarker); // remove
    }
    
    twittermarker = L.marker(e.latlng);
       
    decarbnowMap.addLayer(twittermarker);

    let hash = encode(e.latlng.lat, e.latlng.lng);

    let text = '<p>Tweet about'+
    '<dl>'+
    '<dd><img src="/dist/img/action.png" width="14">climate action</dd>'+
    '<dd><img src="/dist/img/pollution.png" width="14">pollution</dd>'+
    '<dd><img src="/dist/img/transition.png" width="14">climate transition</dd>'+
    '</dl>'+
    'taking place here using the buttons below:</p>' +

    '<a target="_blank" href="https://twitter.com/share?ref_src=twsrc%5Etfw" class="twitter-share-button" data-show-count="false" data-text="#decarbnow #climateaction @' + hash + '">#decarbnow #climateaction @' + hash + '</a> #decarbnow #climateaction @' + hash +'<br />'+
    '<a target="_blank" href="https://twitter.com/share?ref_src=twsrc%5Etfw" class="twitter-share-button" data-show-count="false" data-text="#decarbnow #transition @' + hash + '">#decarbnow #transition @' + hash + '</a> #decarbnow #transition @' + hash + '<br />'+
    '<a target="_blank" href="https://twitter.com/share?ref_src=twsrc%5Etfw" class="twitter-share-button" data-show-count="false" data-text="#decarbnow #pollution @' + hash + '">#decarbnow #pollution @' + hash + '</a> #decarbnow #pollution @' + hash;
    /*
    showGeoLoc
        .setLatLng(e.latlng)
        .setContent(text)
        .openOn(decarbnowMap);
    */
    sidebar.show()
    sidebar.setContent(text)

    console.log(e);
    TwitterWidgetsLoader.load(function(err, twttr) {
        if (err) {
            showError();
            //do some graceful degradation / fallback
            return;
        }

        twttr.widgets.load();
    });
});

decarbnowMap.on('click', function () {
    sidebar.hide();
    if (typeof twittermarker !== 'undefined') { // check
        decarbnowMap.removeLayer(twittermarker); // remove
    }
})


//**************************************************************************
// initiation
//**************************************************************************

initializeMarkers();
refreshMarkers();

// add GeoJSON layers to the map once all files are loaded
$.getJSON("/dist/World_rastered.geojson",function(no2){
    $.getJSON("/dist/global_power_plant_database.geojson",function(coalplants) {

        let baseLayers = {
            "Satellite": createBackgroundMapSat(),
            "Dark": createBackgroundMap().addTo(decarbnowMap)
        };
        let overlays = {
            "NO2 Pollution by NASA OMI": L.geoJson(no2, {style: pollutionStyle}).addTo(decarbnowMap),
            "Coal-fired power stations > 1.000 MW": L.geoJson(coalplants, {
                style: function(feature) {
                    return {color: '#d8d4d4'};
                },
                pointToLayer: function(feature, latlng) {
                    return new L.CircleMarker(latlng, {radius: feature.properties.capacity_mw/1000/0.5, stroke: false, fillOpacity: 0.5});
                },
                onEachFeature: function (feature, layer) {
                    layer.bindPopup('<table><tr><td>Name:</td><td>' + feature.properties.name + '</td></tr>' + 
                                    '<tr><td>Fuel:</td><td>' + feature.properties.primary_fuel + '</td></tr>'+
                                    '<tr><td>Capacity:</td><td>' + feature.properties.capacity_mw + ' MW</td></tr>'+
                                    '<tr><td>Owner:</td><td>' + feature.properties.owner + '</td></tr>'+
                                    '<tr><td>Source:</td><td><a href =' + feature.properties.url +' target = popup>'  + feature.properties.source + '</a></td></tr>'+
                                    '</table>');
                }
            }).addTo(decarbnowMap)
        };
        
        decarbnowMap.addLayer(markerClusters);
        L.control.layers(baseLayers, overlays).addTo(decarbnowMap);
        decarbnowMap.addControl(sidebar);

    });
});

L.control.markers({ position: 'topleft' }).addTo(decarbnowMap);
L.control.zoom({ position: 'topleft' }).addTo(decarbnowMap);

window.setInterval(refreshMarkers, 30000);