# Arquitectura inicial de HOOD HEAD

## Frontend
Angular y TypeScript. Presenta el catálogo y permite al cliente interactuar con la tienda.

## Backend
ASP.NET Core Web API con C#. Expone endpoints HTTP y centraliza las reglas del negocio.

## Stock
Google Sheets y Google Apps Script son los recursos existentes para evaluar como fuente inicial del inventario. Antes de integrar, definiremos cómo evitar inconsistencias de stock.

## Base de datos
La base de datos definitiva se decidirá y configurará en una etapa posterior.

## Flujo general
Cliente -> Angular -> API ASP.NET Core -> fuente de datos autorizada.
