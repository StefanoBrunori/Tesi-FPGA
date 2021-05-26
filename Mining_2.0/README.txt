Ho diviso la funzione crittografica in due moduli ed una FSM che gestisce i passaggi:

Modulo di Preprocessing:
  - Inizialmente il messaggio viene salvato in una memoria di 100 blocchi da 512-bit ciascuno;
  - A quel punto viene applicata la fase di preprocessing, in cui il messaggio viene imbottito con un bit "1", un numero variabile di zeri 
    e la lunghezza del messaggio originale come intero di 64 bit Big-Endian;
  - A questo punto i blocchi della memoria vengono passati man mano al modulo Chunks;
  
Modulo Chunks:
  - In questo modulo vengono eseguite le operazioni principali della SHA-256 su ogni blocco passato dalla memoria;
  - Una volta eseguiti i passaggi su tutti i blocchi, i valori hash verrano concatenati per formare il messaggio (digest) finale
  
Da notare: La funzione esegue effettivamente una crittografia, tuttavia l'hash ritornato non corrisponde all'hash corretto 
(verificato tramite il sito: https://passwordsgenerator.net/sha256-hash-generator/). La funzione comunque esegue il suo lavoro di crittografia variando 
notevolemente l'hash finale ad ogni minimo cambiamento dell'output.
