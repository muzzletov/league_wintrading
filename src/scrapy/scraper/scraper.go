package scraper

import (
	"fmt"
	"github.com/muzzletov/parseur"
	"log"
	"strings"
)

type Scraper struct {
	client *parseur.WebClient
}

func NewScraper() *Scraper {
	c := parseur.NewClient()
	return &Scraper{client: c}
}

func (s *Scraper) BuildURL(name string) string {
	return fmt.Sprintf(
		"https://porofessor.gg/partial/live-partial/%s/%s",
		"euw",
		strings.Replace(name, "#", "-", 1),
	)
}

func (s *Scraper) FetchAndParse(name string) *[]string {
	var names []string = nil

	u := s.BuildURL(name)
	callback := func(p *parseur.Parser) {
		list := p.GetTags(".cards-list")

		if list != nil &&
			len(*list) >= 2 &&
			(*list)[0].Body.End != parseur.PARSING &&
			(*list)[1].Body.End != parseur.PARSING {
			p.InBound = func(_ int) bool {
				return false
			}
		}
	}

	p, err := s.client.FetchParseAsync(u, &callback)
	names = make([]string, 5)
	items := p.GetTags(".cards-list")

	if items == nil || len(*items) < 2 {
		log.Print("is the game still on-going?")
		return nil
	}

	for _, j := range *items {
		has := false

		if len(j.Children) < 5 {
			break
		}

		for i, item := range j.Children {
			child := item.Children[0]

			if child.Attributes["data-summonername"] == name {
				has = true
				break
			}

			names[i] = child.Attributes["data-summonername"]
		}

		if !has {
			return &names
		}
	}

	log.Printf("failed to parse file: %v", err)
	return nil

}
