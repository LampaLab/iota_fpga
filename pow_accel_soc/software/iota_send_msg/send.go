
package main

import (
	"fmt"
	"time"

	gmam "github.com/habpygo/mam.client.go"
)

var address = "TLGIMYWLDSOXUMUXZAGPZTYTGUOUAABMTFIYQPEEY9VBTIYVOEQKEK9EMHPBAMNGXSUDZRSUWQRUNDIMD"

var seed = "DETZCWHMSWSDOTFPEYZZUJDKMO9FAQZLHSEMTNIEUK9NRFSXJNIFZ9CNSHMUIXJC9CROYAMCWXRT9SZFN"

func main() {
	
	//WARNING: The nodes have a nasty habit to go on/off line without warning or notice. If this happens try to find another one.
	c, err := gmam.NewConnection("http://5.9.149.169:14265", seed)
	if err != nil {
		panic(err)
	}

	msgTime := time.Now().UTC().String()
	message := "Message from DE10-nano on: " + msgTime

	id, err := gmam.Send(address, 0, message, c)
	if err != nil {
		panic(err)
	}

	fmt.Printf("Sent Transaction: %v\n", id)
}
