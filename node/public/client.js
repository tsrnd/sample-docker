var socket = io();

function logger(msg) {
    $("#logger").text(msg);
}

function stream() {
    var canv = document.getElementById("prev"),
    context = canv.getContext("2d"),
    video = document.getElementById("video"),

    canv.width = 320 ;
    canv.height = 240;

    context.width = canv.width;
    context.height = canv.height;

    function success(stream) {
        video.src = window.URL.createObjectURL(stream);
        logger("Camera loaded [OKAY]");
    }

    function failure(stream) {
        logger("Failed loading camera");
    }

    function viewVideo(video, context) {
        context.drawImage(video, 0, 0, context.width, context.height);
        socket.emit("stream", canv.toDataURL("image/webp"));
    }

    $(function() {
        navigator.getUserMedia = navigator.getUserMedia || navigator.webkitGetUserMedia || navigator.mozGetUserMedia;

        if (navigator.getUserMedia) {
            navigator.getUserMedia({video: true}, success, failure);
        }

        setInterval(function() {
            viewVideo(video, context);
        }, 1000);
    });
}

function view() {
    logger("Wait...");
    socket.on("stream", function (video) {
        var img = document.getElementById("img");
        img.src = video;
        logger("stream play");
    });
}
