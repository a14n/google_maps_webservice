library google_maps_webservice.places.test;

import 'dart:convert';
import 'package:http/http.dart';
import 'package:test/test.dart';
import 'package:google_maps_webservice/places.dart';

launch([Client client]) async {
  final apiKey = "MY_API_KEY";
  GoogleMapsPlaces places = new GoogleMapsPlaces(apiKey, client);

  tearDownAll(() {
    places.dispose();
  });

  group("Google Maps Places", () {
    group("nearbysearch build url", () {
      test("basic", () {
        String url = places.buildNearbySearchUrl(
            location: new Location(-33.8670522, 151.1957362), radius: 500);

        expect(
            url,
            equals(
                "https://maps.googleapis.com/maps/api/place/nearbysearch/json?key=$apiKey&location=-33.8670522,151.1957362&radius=500"));
      });

      test("with type and keyword", () {
        String url = places.buildNearbySearchUrl(
            location: new Location(-33.8670522, 151.1957362),
            radius: 500,
            type: "restaurant",
            keyword: "cruise");

        expect(
            url,
            equals(
                "https://maps.googleapis.com/maps/api/place/nearbysearch/json?key=$apiKey&location=-33.8670522,151.1957362&radius=500&type=restaurant&keyword=cruise"));
      });

      test("with language", () {
        String url = places.buildNearbySearchUrl(
            location: new Location(-33.8670522, 151.1957362),
            radius: 500,
            language: "fr");

        expect(
            url,
            equals(
                "https://maps.googleapis.com/maps/api/place/nearbysearch/json?key=$apiKey&location=-33.8670522,151.1957362&radius=500&language=fr"));
      });

      test("with min and maxprice", () {
        String url = places.buildNearbySearchUrl(
            location: new Location(-33.8670522, 151.1957362),
            radius: 500,
            minprice: PriceLevel.free,
            maxprice: PriceLevel.veryExpensive);

        expect(
            url,
            equals(
                "https://maps.googleapis.com/maps/api/place/nearbysearch/json?key=$apiKey&location=-33.8670522,151.1957362&radius=500&minprice=0&maxprice=4"));
      });

      test("build url with name", () {
        String url = places.buildNearbySearchUrl(
            location: new Location(-33.8670522, 151.1957362),
            radius: 500,
            name: "cruise");

        expect(
            url,
            equals(
                "https://maps.googleapis.com/maps/api/place/nearbysearch/json?key=$apiKey&location=-33.8670522,151.1957362&radius=500&name=cruise"));
      });

      test("with rankby", () {
        String url = places.buildNearbySearchUrl(
            location: new Location(-33.8670522, 151.1957362),
            rankby: "distance",
            name: "cruise");

        expect(
            url,
            equals(
                "https://maps.googleapis.com/maps/api/place/nearbysearch/json?key=$apiKey&location=-33.8670522,151.1957362&name=cruise&rankby=distance"));
      });

      test("with rankby without required params", () {
        try {
          places.buildNearbySearchUrl(
              location: new Location(-33.8670522, 151.1957362),
              rankby: "distance",
              name: "cruise");
        } catch (e) {
          expect(
              (e as ArgumentError).message,
              equals(
                  "If 'rankby=distance' is specified, then one or more of 'keyword', 'name', or 'type' is required."));
        }
      });

      test("with rankby and radius", () {
        try {
          places.buildNearbySearchUrl(
              location: new Location(-33.8670522, 151.1957362),
              radius: 500,
              rankby: "distance");
        } catch (e) {
          expect(
              (e as ArgumentError).message,
              equals(
                  "'rankby' must not be included if 'radius' is specified."));
        }
      });
    });

    group("textsearch build url", () {
      test("basic", () {
        expect(
            places.buildTextSearchUrl(query: "123 Main Street"),
            equals(
                "https://maps.googleapis.com/maps/api/place/textsearch/json?key=$apiKey&query=${Uri.encodeComponent("123 Main Street")}"));
      });

      test("with location", () {
        expect(
            places.buildTextSearchUrl(
                query: "123 Main Street",
                location: new Location(-33.8670522, 151.1957362)),
            equals(
                "https://maps.googleapis.com/maps/api/place/textsearch/json?key=$apiKey&query=${Uri.encodeComponent("123 Main Street")}&location=-33.8670522,151.1957362"));
      });

      test("with radius", () {
        expect(
            places.buildTextSearchUrl(query: "123 Main Street", radius: 500),
            equals(
                "https://maps.googleapis.com/maps/api/place/textsearch/json?key=$apiKey&query=${Uri.encodeComponent("123 Main Street")}&radius=500"));
      });

      test("with language", () {
        expect(
            places.buildTextSearchUrl(query: "123 Main Street", language: "fr"),
            equals(
                "https://maps.googleapis.com/maps/api/place/textsearch/json?key=$apiKey&query=${Uri.encodeComponent("123 Main Street")}&language=fr"));
      });

      test("with minprice and maxprice", () {
        expect(
            places.buildTextSearchUrl(
                query: "123 Main Street",
                minprice: PriceLevel.free,
                maxprice: PriceLevel.veryExpensive),
            equals(
                "https://maps.googleapis.com/maps/api/place/textsearch/json?key=$apiKey&query=${Uri.encodeComponent("123 Main Street")}&minprice=0&maxprice=4"));
      });

      test("with opennow", () {
        expect(
            places.buildTextSearchUrl(query: "123 Main Street", opennow: true),
            equals(
                "https://maps.googleapis.com/maps/api/place/textsearch/json?key=$apiKey&query=${Uri.encodeComponent("123 Main Street")}&opennow=true"));
      });

      test("with pagetoken", () {
        expect(
            places.buildTextSearchUrl(
                query: "123 Main Street", pagetoken: "egdsfdsfdsf"),
            equals(
                "https://maps.googleapis.com/maps/api/place/textsearch/json?key=$apiKey&query=${Uri.encodeComponent("123 Main Street")}&pagetoken=egdsfdsfdsf"));
      });

      test("with type", () {
        expect(
            places.buildTextSearchUrl(
                query: "123 Main Street", type: "hospital"),
            equals(
                "https://maps.googleapis.com/maps/api/place/textsearch/json?key=$apiKey&query=${Uri.encodeComponent("123 Main Street")}&type=hospital"));
      });
    });

    group("details build url", () {
      test("with place_id", () {
        expect(
            places.buildDetailsUrl(placeId: "PLACE_ID"),
            equals(
                "https://maps.googleapis.com/maps/api/place/details/json?key=$apiKey&placeid=PLACE_ID"));
      });

      test("with reference", () {
        expect(
            places.buildDetailsUrl(reference: "REF"),
            equals(
                "https://maps.googleapis.com/maps/api/place/details/json?key=$apiKey&reference=REF"));
      });

      test("with extensions", () {
        expect(
            places.buildDetailsUrl(
                placeId: "PLACE_ID", extensions: "review_summary"),
            equals(
                "https://maps.googleapis.com/maps/api/place/details/json?key=$apiKey&placeid=PLACE_ID&extensions=review_summary"));
      });

      test("with extensions", () {
        expect(
            places.buildDetailsUrl(placeId: "PLACE_ID", language: "fr"),
            equals(
                "https://maps.googleapis.com/maps/api/place/details/json?key=$apiKey&placeid=PLACE_ID&language=fr"));
      });

      test("with place_id and reference", () {
        try {
          places.buildDetailsUrl(placeId: "PLACE_ID", reference: "REF");
        } catch (e) {
          expect((e as ArgumentError).message,
              equals("You must supply either 'placeid' or 'reference'"));
        }
      });
    });

    group("add", () {});

    group("delete", () {});

    group("photo", () {});

    group("autocomplete build url", () {
      test("basic", () {
        expect(
            places.buildAutocompleteUrl(input: "Amoeba"),
            equals(
                "https://maps.googleapis.com/maps/api/place/autocomplete/json?key=$apiKey&input=Amoeba"));
      });

      test("with offset", () {
        expect(
            places.buildAutocompleteUrl(input: "Amoeba", offset: 3),
            equals(
                "https://maps.googleapis.com/maps/api/place/autocomplete/json?key=$apiKey&input=Amoeba&offset=3"));
      });

      test("with location", () {
        expect(
            places.buildAutocompleteUrl(
                input: "Amoeba",
                location: new Location(-33.8670522, 151.1957362)),
            equals(
                "https://maps.googleapis.com/maps/api/place/autocomplete/json?key=$apiKey&input=Amoeba&location=-33.8670522,151.1957362"));
      });

      test("with radius", () {
        expect(
            places.buildAutocompleteUrl(input: "Amoeba", radius: 500),
            equals(
                "https://maps.googleapis.com/maps/api/place/autocomplete/json?key=$apiKey&input=Amoeba&radius=500"));
      });

      test("with language", () {
        expect(
            places.buildAutocompleteUrl(input: "Amoeba", language: "fr"),
            equals(
                "https://maps.googleapis.com/maps/api/place/autocomplete/json?key=$apiKey&input=Amoeba&language=fr"));
      });

      test("with types", () {
        expect(
            places.buildAutocompleteUrl(
                input: "Amoeba", types: ["geocode", "establishment"]),
            equals(
                "https://maps.googleapis.com/maps/api/place/autocomplete/json?key=$apiKey&input=Amoeba&types=geocode|establishment"));
      });

      test("with components", () {
        expect(
            places.buildAutocompleteUrl(
                input: "Amoeba",
                components: [new Component(Component.country, "fr")]),
            equals(
                "https://maps.googleapis.com/maps/api/place/autocomplete/json?key=$apiKey&input=Amoeba&components=country:fr"));
      });

      test("with strictbounds", () {
        expect(
            places.buildAutocompleteUrl(input: "Amoeba", strictbounds: true),
            equals(
                "https://maps.googleapis.com/maps/api/place/autocomplete/json?key=$apiKey&input=Amoeba&strictbounds=true"));
      });
    });

    group("queryautocomplete", () {
      test("basic", () {
        expect(
            places.buildQueryAutocompleteUrl(input: "Amoeba"),
            equals(
                "https://maps.googleapis.com/maps/api/place/queryautocomplete/json?key=$apiKey&input=Amoeba"));
      });

      test("with offset", () {
        expect(
            places.buildQueryAutocompleteUrl(input: "Amoeba", offset: 3),
            equals(
                "https://maps.googleapis.com/maps/api/place/queryautocomplete/json?key=$apiKey&input=Amoeba&offset=3"));
      });

      test("with location", () {
        expect(
            places.buildQueryAutocompleteUrl(
                input: "Amoeba",
                location: new Location(-33.8670522, 151.1957362)),
            equals(
                "https://maps.googleapis.com/maps/api/place/queryautocomplete/json?key=$apiKey&input=Amoeba&location=-33.8670522,151.1957362"));
      });

      test("with radius", () {
        expect(
            places.buildQueryAutocompleteUrl(input: "Amoeba", radius: 500),
            equals(
                "https://maps.googleapis.com/maps/api/place/queryautocomplete/json?key=$apiKey&input=Amoeba&radius=500"));
      });

      test("with language", () {
        expect(
            places.buildQueryAutocompleteUrl(input: "Amoeba", language: "fr"),
            equals(
                "https://maps.googleapis.com/maps/api/place/queryautocomplete/json?key=$apiKey&input=Amoeba&language=fr"));
      });
    });

    test("decode response", () {
      PlacesSearchResponse response =
          new PlacesSearchResponse.fromJson(JSON.decode(_responseExample));

      expect(response.isOkay, isTrue);
      expect(response.results, hasLength(equals(4)));
      expect(response.results.first.geometry.location.lat, equals(-33.870775));
      expect(response.results.first.geometry.location.lng, equals(151.199025));
      expect(
          response.results.first.icon,
          equals(
              "http://maps.gstatic.com/mapfiles/place_api/icons/travel_agent-71.png"));
      expect(response.results.first.id,
          equals("21a0b251c9b8392186142c798263e289fe45b4aa"));
      expect(response.results.first.name, equals("Rhythmboat Cruises"));
      expect(response.results.first.openingHours.openNow, isTrue);
      expect(response.results.first.photos, hasLength(equals(1)));
      expect(response.results.first.photos.first.height, equals(270));
      expect(response.results.first.photos.first.width, equals(519));
      expect(
          response.results.first.photos.first.photoReference,
          equals(
              "CnRnAAAAF-LjFR1ZV93eawe1cU_3QNMCNmaGkowY7CnOf-kcNmPhNnPEG9W979jOuJJ1sGr75rhD5hqKzjD8vbMbSsRnq_Ni3ZIGfY6hKWmsOf3qHKJInkm4h55lzvLAXJVc-Rr4kI9O1tmIblblUpg2oqoq8RIQRMQJhFsTr5s9haxQ07EQHxoUO0ICubVFGYfJiMUPor1GnIWb5i8"));
      expect(response.results.first.placeId,
          equals("ChIJyWEHuEmuEmsRm9hTkapTCrk"));
      expect(response.results.first.scope, equals("GOOGLE"));
      expect(response.results.first.altIds, hasLength(equals(1)));
      expect(response.results.first.altIds.first.placeId,
          equals("D9iJyWEHuEmuEmsRm9hTkapTCrk"));
      expect(response.results.first.altIds.first.scope, equals("APP"));
      expect(
          response.results.first.reference,
          equals(
              "CoQBdQAAAFSiijw5-cAV68xdf2O18pKIZ0seJh03u9h9wk_lEdG-cP1dWvp_QGS4SNCBMk_fB06YRsfMrNkINtPez22p5lRIlj5ty_HmcNwcl6GZXbD2RdXsVfLYlQwnZQcnu7ihkjZp_2gk1-fWXql3GQ8-1BEGwgCxG-eaSnIJIBPuIpihEhAY1WYdxPvOWsPnb2-nGb6QGhTipN0lgaLpQTnkcMeAIEvCsSa0Ww"));
      expect(response.results.first.types,
          equals(["travel_agency", "restaurant", "food", "establishment"]));
      expect(response.results.first.vicinity,
          equals("Pyrmont Bay Wharf Darling Dr, Sydney"));
    });
  });
}

final _responseExample = '''
{
   "html_attributions" : [],
   "results" : [
      {
         "geometry" : {
            "location" : {
               "lat" : -33.870775,
               "lng" : 151.199025
            }
         },
         "icon" : "http://maps.gstatic.com/mapfiles/place_api/icons/travel_agent-71.png",
         "id" : "21a0b251c9b8392186142c798263e289fe45b4aa",
         "name" : "Rhythmboat Cruises",
         "opening_hours" : {
            "open_now" : true
         },
         "photos" : [
            {
               "height" : 270,
               "html_attributions" : [],
               "photo_reference" : "CnRnAAAAF-LjFR1ZV93eawe1cU_3QNMCNmaGkowY7CnOf-kcNmPhNnPEG9W979jOuJJ1sGr75rhD5hqKzjD8vbMbSsRnq_Ni3ZIGfY6hKWmsOf3qHKJInkm4h55lzvLAXJVc-Rr4kI9O1tmIblblUpg2oqoq8RIQRMQJhFsTr5s9haxQ07EQHxoUO0ICubVFGYfJiMUPor1GnIWb5i8",
               "width" : 519
            }
         ],
         "place_id" : "ChIJyWEHuEmuEmsRm9hTkapTCrk",
         "scope" : "GOOGLE",
         "alt_ids" : [
            {
               "place_id" : "D9iJyWEHuEmuEmsRm9hTkapTCrk",
               "scope" : "APP"
            }
         ],
         "reference" : "CoQBdQAAAFSiijw5-cAV68xdf2O18pKIZ0seJh03u9h9wk_lEdG-cP1dWvp_QGS4SNCBMk_fB06YRsfMrNkINtPez22p5lRIlj5ty_HmcNwcl6GZXbD2RdXsVfLYlQwnZQcnu7ihkjZp_2gk1-fWXql3GQ8-1BEGwgCxG-eaSnIJIBPuIpihEhAY1WYdxPvOWsPnb2-nGb6QGhTipN0lgaLpQTnkcMeAIEvCsSa0Ww",
         "types" : [ "travel_agency", "restaurant", "food", "establishment" ],
         "vicinity" : "Pyrmont Bay Wharf Darling Dr, Sydney"
      },
      {
         "geometry" : {
            "location" : {
               "lat" : -33.866891,
               "lng" : 151.200814
            }
         },
         "icon" : "http://maps.gstatic.com/mapfiles/place_api/icons/restaurant-71.png",
         "id" : "45a27fd8d56c56dc62afc9b49e1d850440d5c403",
         "name" : "Private Charter Sydney Habour Cruise",
         "photos" : [
            {
               "height" : 426,
               "html_attributions" : [],
               "photo_reference" : "CnRnAAAAL3n0Zu3U6fseyPl8URGKD49aGB2Wka7CKDZfamoGX2ZTLMBYgTUshjr-MXc0_O2BbvlUAZWtQTBHUVZ-5Sxb1-P-VX2Fx0sZF87q-9vUt19VDwQQmAX_mjQe7UWmU5lJGCOXSgxp2fu1b5VR_PF31RIQTKZLfqm8TA1eynnN4M1XShoU8adzJCcOWK0er14h8SqOIDZctvU",
               "width" : 640
            }
         ],
         "place_id" : "ChIJqwS6fjiuEmsRJAMiOY9MSms",
         "scope" : "GOOGLE",
         "reference" : "CpQBhgAAAFN27qR_t5oSDKPUzjQIeQa3lrRpFTm5alW3ZYbMFm8k10ETbISfK9S1nwcJVfrP-bjra7NSPuhaRulxoonSPQklDyB-xGvcJncq6qDXIUQ3hlI-bx4AxYckAOX74LkupHq7bcaREgrSBE-U6GbA1C3U7I-HnweO4IPtztSEcgW09y03v1hgHzL8xSDElmkQtRIQzLbyBfj3e0FhJzABXjM2QBoUE2EnL-DzWrzpgmMEulUBLGrtu2Y",
         "types" : [ "restaurant", "food", "establishment" ],
         "vicinity" : "Australia"
      },
      {
         "geometry" : {
            "location" : {
               "lat" : -33.870943,
               "lng" : 151.190311
            }
         },
         "icon" : "http://maps.gstatic.com/mapfiles/place_api/icons/restaurant-71.png",
         "id" : "30bee58f819b6c47bd24151802f25ecf11df8943",
         "name" : "Bucks Party Cruise",
         "opening_hours" : {
            "open_now" : true
         },
         "photos" : [
            {
               "height" : 600,
               "html_attributions" : [],
               "photo_reference" : "CnRnAAAA48AX5MsHIMiuipON_Lgh97hPiYDFkxx_vnaZQMOcvcQwYN92o33t5RwjRpOue5R47AjfMltntoz71hto40zqo7vFyxhDuuqhAChKGRQ5mdO5jv5CKWlzi182PICiOb37PiBtiFt7lSLe1SedoyrD-xIQD8xqSOaejWejYHCN4Ye2XBoUT3q2IXJQpMkmffJiBNftv8QSwF4",
               "width" : 800
            }
         ],
         "place_id" : "ChIJLfySpTOuEmsRsc_JfJtljdc",
         "scope" : "GOOGLE",
         "reference" : "CoQBdQAAANQSThnTekt-UokiTiX3oUFT6YDfdQJIG0ljlQnkLfWefcKmjxax0xmUpWjmpWdOsScl9zSyBNImmrTO9AE9DnWTdQ2hY7n-OOU4UgCfX7U0TE1Vf7jyODRISbK-u86TBJij0b2i7oUWq2bGr0cQSj8CV97U5q8SJR3AFDYi3ogqEhCMXjNLR1k8fiXTkG2BxGJmGhTqwE8C4grdjvJ0w5UsAVoOH7v8HQ",
         "types" : [ "restaurant", "food", "establishment" ],
         "vicinity" : "37 Bank St, Pyrmont"
      },
      {
         "geometry" : {
            "location" : {
               "lat" : -33.867591,
               "lng" : 151.201196
            }
         },
         "icon" : "http://maps.gstatic.com/mapfiles/place_api/icons/travel_agent-71.png",
         "id" : "a97f9fb468bcd26b68a23072a55af82d4b325e0d",
         "name" : "Australian Cruise Group",
         "opening_hours" : {
            "open_now" : true
         },
         "photos" : [
            {
               "height" : 242,
               "html_attributions" : [],
               "photo_reference" : "CnRnAAAABjeoPQ7NUU3pDitV4Vs0BgP1FLhf_iCgStUZUr4ZuNqQnc5k43jbvjKC2hTGM8SrmdJYyOyxRO3D2yutoJwVC4Vp_dzckkjG35L6LfMm5sjrOr6uyOtr2PNCp1xQylx6vhdcpW8yZjBZCvVsjNajLBIQ-z4ttAMIc8EjEZV7LsoFgRoU6OrqxvKCnkJGb9F16W57iIV4LuM",
               "width" : 200
            }
         ],
         "place_id" : "ChIJrTLr-GyuEmsRBfy61i59si0",
         "scope" : "GOOGLE",
         "reference" : "CoQBeQAAAFvf12y8veSQMdIMmAXQmus1zqkgKQ-O2KEX0Kr47rIRTy6HNsyosVl0CjvEBulIu_cujrSOgICdcxNioFDHtAxXBhqeR-8xXtm52Bp0lVwnO3LzLFY3jeo8WrsyIwNE1kQlGuWA4xklpOknHJuRXSQJVheRlYijOHSgsBQ35mOcEhC5IpbpqCMe82yR136087wZGhSziPEbooYkHLn9e5njOTuBprcfVw",
         "types" : [ "travel_agency", "restaurant", "food", "establishment" ],
         "vicinity" : "32 The Promenade, King Street Wharf 5, Sydney"
      }
   ],
   "status" : "OK"
}
''';
