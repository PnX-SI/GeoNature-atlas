// Simple glossaire term replacement with Bootstrap 5 tooltips

fetch(urlGlossaire)
    .then((response) => response.json())
    .then((glossaire) => {
        // Build terms map
        const termsMap = new Map();
        glossaire.forEach((entry) => {
            if (!entry.term || !entry.description) return;
            entry.term.split(",").forEach((variation) => {
                const term = variation.trim();
                if (term) {
                    termsMap.set(term.toLowerCase(), entry.description);
                }
            });
        });

        // Process each .taxhub-attr element
        document.querySelectorAll(".taxhub-attr").forEach((element) => {
            let html = element.innerHTML;
            Array.from(termsMap.keys()).forEach((term) => {
                const description = termsMap.get(term);
                const regex = new RegExp(`\\b${term}\\b`, "gi");
                html = html.replace(regex, (match) => {
                    return `<span class="glossarizer_replaced" data-bs-toggle="tooltip" data-bs-title="${description}">${match}</span>`;
                });
            });

            element.innerHTML = html;
        });

        // Initialize Bootstrap tooltips
        document
            .querySelectorAll('[data-bs-toggle="tooltip"]')
            .forEach((el) => {
                if (!bootstrap.Tooltip.getInstance(el)) {
                    new bootstrap.Tooltip(el);
                }
            });
    })
    .catch((error) => {
        console.error("Error loading glossaire:", error);
    });
