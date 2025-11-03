import js from "@eslint/js";
import globals from "globals";
import eslintPluginPrettierRecommended from "eslint-plugin-prettier/recommended";
import { defineConfig } from "eslint/config";

export default defineConfig([
    eslintPluginPrettierRecommended,
    {
        files: ["**/*.js"],
        plugins: {
            js,
        },
        extends: ["js/recommended"],
        rules: {
            semi: "error",
            eqeqeq: "error",
            "prefer-const": "error",
            "no-undef": "off",
            "no-unused-vars": "off",
        },
    },
    {
        ignores: ["custom", "sample"],
    },
]);
