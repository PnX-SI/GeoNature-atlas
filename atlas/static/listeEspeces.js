function initializePlugins() {
    $(".lazy").lazy({
        effect: "fadeIn",
        effectTime: 2000,
        threshold: 0,
        appendScroll: $("#taxonList"),
    });
}

function filterText() {
    $("#taxonInput").on("keyup", function () {
        var value = $(this).val().toLowerCase();

        $("#taxonList li").filter(function () {
            console.log($(this).text().toLowerCase().replace(/\s+/g, " "), value);
            var match = $(this).text().toLowerCase().replace(/\s+/g, " ").indexOf(value) > -1;
            this.style.setProperty("display", match ? "flex" : "none", "important");
        });
    });
}

$(document).ready(function () {
    initializePlugins();
    filterText();
});
