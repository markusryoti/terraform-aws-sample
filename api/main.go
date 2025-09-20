package main

import (
	"log"
	"net/http"
)

func main() {
	mux := http.NewServeMux()

	mux.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		w.Write([]byte("Hello world"))
	})

	log.Println("starting api")

	log.Fatal(http.ListenAndServe("0.0.0.0:8080", mux))
}
