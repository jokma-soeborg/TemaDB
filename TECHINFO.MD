# Tech Info #

Dette dokument indeholder tips/tricks til løsningen

## Problemer ##

* [Q01: Encrypted password fejler](#Q01)



<a name="Q01"></a>
## Q1: Encrypted password fejler.
Du har nok enten ikke oprettet en AES key fil, eller også tilgår du databasen med en forkert AES fil. 

* Kør `.\TemaDb.ps1 -mode CreateAESKey` hvis dette er den eneste PowerShell instans, som tilgår din database, og hvis ikke, så kopier filen `config\aes.key` fra en allerede eksisterende installation
* Hvis du oprettede en ny `aes.key` fil, skal du derefter kører `.\TemaDb.ps1 -mode SetPwd`

