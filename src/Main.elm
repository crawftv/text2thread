module Main exposing (main)

import Browser
import Element exposing (alignLeft, paddingEach)
import Element.Border as Border
import Element.Input as Input
import Element.Region as Region
import Html
import Http
import Json.Decode as Decode exposing (Decoder, int, list, string)
import Json.Decode.Pipeline as Pipeline exposing (required)
import RemoteData exposing (RemoteData(..), WebData)
import RemoteData.Http


type alias Model =
    { text : WebData Text }


type alias Text =
    { text : List Paragraph }


type alias Paragraph =
    { depth : Int
    , pre_cleaned_words : String
    }


type Msg
    = HandleResponse (WebData Text)
    | GotJson


init : () -> ( Model, Cmd Msg )
init _ =
    ( { text = Loading }
    , RemoteData.Http.getWithConfig RemoteData.Http.defaultConfig "http://localhost:5000/api" HandleResponse textDecoder
    )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


textDecoder : Decoder Text
textDecoder =
    Decode.succeed Text
        |> required "data" (list paragraphDecoder)


paragraphDecoder : Decoder Paragraph
paragraphDecoder =
    Decode.succeed Paragraph
        |> required "depth" int
        |> required "pre_cleaned_words" string


decodeError : Http.Error -> Browser.Document Msg
decodeError error =
    case error of
        Http.BadUrl string ->
            { title = "Bad Url"
            , body = [ Element.layout [] (Element.text ("Error: " ++ string)) ]
            }

        Http.Timeout ->
            { title = "Timeout"
            , body = [ Element.layout [] (Element.text "timeout") ]
            }

        Http.NetworkError ->
            { title = "Network Error"
            , body = [ Element.layout [] (Element.text "network error") ]
            }

        Http.BadStatus int ->
            { title = "Bad Status"
            , body = [ Element.layout [] (Element.text ("Error: " ++ String.fromInt int)) ]
            }

        Http.BadBody string ->
            { title = "Bad Body"
            , body = [ Element.layout [] (Element.text ("Error: " ++ string)) ]
            }


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotJson ->
            ( model, Cmd.none )

        HandleResponse data ->
            ( { model | text = data }, Cmd.none )


view : Model -> Browser.Document Msg
view model =
    case model.text of
        Failure error ->
            decodeError error

        Loading ->
            { title = "Loading"
            , body = [ Element.layout [] (Element.text "Loading") ]
            }

        Success data ->
            { title = "Home"
            , body = [ Element.layout [] (viewText data) ]
            }

        NotAsked ->
            { title = "Not Asked"
            , body = [ Element.layout [] (Element.text "Not Asked") ]
            }


viewText : Text -> Element.Element Msg
viewText text =
    Element.textColumn [ Region.mainContent ] (List.map viewParagraph text.text)


edges =
    { top = 8
    , right = 0
    , bottom = 8
    , left = 4
    }


viewParagraph : Paragraph -> Element.Element Msg
viewParagraph paragraph =
    Element.row [ paddingEach { edges | left = 4 + paragraph.depth } ]
        [ Element.el [ Element.width (Element.px (paragraph.depth*100)) ] (Element.text "")
        , Element.paragraph [] [ Element.text paragraph.pre_cleaned_words ]
        ]


main =
    Browser.document
        { init = init
        , view = view
        , subscriptions = subscriptions
        , update = update
        }
