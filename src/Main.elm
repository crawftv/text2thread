port module Main exposing (main)

import Browser
import Element
import Element.Border as Border
import Element.Input as Input
import Element.Region as Region
import Html
import Json.Decode as Decode exposing (Decoder, string, int, list)
import Json.Decode.Pipeline as Pipeline exposing (required)


type Model
    = Loading
    | TextLoaded Text


type alias Text =
    { text : List Paragraph }


type alias Paragraph =
    { pre_cleaned_words : List String
    , tags : List String
    , depth : Int
    }


type Msg
    = RecieveText String


--encodeForm : Form -> Encode.Value
--encodeForm form =
--    Encode.object
--        [ ( "storyText", Encode.string form.storyText )
--        , ( "author", Encode.string form.author )
--        , ( "title", Encode.string form.title )
--        , ( "subtitle", Encode.string form.subtitle )
--        , ( "url", Encode.string form.url )
--        ]


init : () -> ( Model, Cmd msg )
init flags =
    ( Loading
    , Cmd.none
    )

port messageReceiver : (Decode.Value-> msg) -> Sub msg

textDecoder : Decoder Text
textDecoder =
    Decode.succeed Text
        |> required (list paragraphDecoder)
paragraphDecoder : Decoder Paragraph
paragraphDecoder =
    Decode.succeed Paragraph
        |> required "pre_cleaned_words" (list string)
        |> required "depth" int
        |> required "tags" (list string)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        RecieveText text->
            ( TextLoaded (Text text)
            , Cmd.none
            )


subscriptions : Model -> Sub Msg
subscriptions _ =
    messageReceiver (textDecoder >> RecieveText)

view : Model -> Browser.Document Msg
view model =
    case model of
        TextLoaded text->
            { title = "Home"
            , body = [ Element.layout [] (viewText model) ]
            }



viewText model= Element.el [Region.mainContent] (Element.text (Debug.toString model) )


main =
    Browser.document
        { init = init
        , view = view
        , subscriptions = subscriptions
        , update = update
        }
