## Installation ##

Download
=====
* Du skal hente OGR2OGR først, og denne hentes her:
http://www.gisinternals.com/release.php

  * Jeg benyttede selv: `release-1911-x64-gdal-3-0-0-mapserver-7-4-0.zip`

  * I Script biblioteket laves et bibliotek der hedder `OGR2OGR`, og indholdet fra ovenstående zip kopieres derefter til denne

  * Derefter køres filen `SDKShell.bat` fra roden af `OGR2OGR` biblioteket en enkelt gang

* Så kopieres filen `Script/config/TemaDb.config.TEMPLATE.json` til ``Script/config/TemaDb.config.json`

  * Derefter tilrettes konfig filen i `Src/Script/config/TemaDb.config.json`

Derefter kan `TemaDb.ps1` startes fra PowerShell

MS SQL
======
For at oprette en TemaMeta Database, skal scripts som du finder under `Db/Scripts` køres fra SSMS, i nummereret rækkefølge, sartende med script 001 i `Version 1.0` biblioteket

## Update ##

Hvis du opdaterer fra en tidligere version, skal du gøre flg:
* Kør alle MS SQL fra nyere versioner i `Scripts` folderen i nummereret rækkefølge
* Overskriv alle eksisterende filer
* Kontroller filer ved navn `Script\config\*.Template.json` for opdateret parametere, og overfør disse til din eksisterende `TemaDb.config.json` fil og tilret disse
