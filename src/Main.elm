module SubmitStory exposing (main)

import Browser
import Element
import Element.Border as Border
import Element.Input as Input
import Element.Region as Region
import Http
import Html
import Json.Encode as Encode


type alias Form =
    { storyText : String
    , author : String
    , title : String
    , subtitle : String
    , url : String
    }


setFormStoryText : String -> Form -> Form
setFormStoryText newStory form =
    { form | storyText = newStory }


setFormAuthor : String -> Form -> Form
setFormAuthor newAuthor form =
    { form | author = newAuthor }


setFormTitle : String -> Form -> Form
setFormTitle newTitle form =
    { form | title = newTitle }


setFormSubtitle : String -> Form -> Form
setFormSubtitle newSubtitle form =
    { form | subtitle = newSubtitle }


setFormUrl : String -> Form -> Form
setFormUrl newUrl form =
    { form | url = newUrl }


type alias Model =
    { form :Form }


type Msg
    = ChangeStoryText String
    | ChangeAuthor String
    | ChangeTitle String
    | ChangeSubtitle String
    | ChangeUrl String
    | Submit
    | SubmissionComplete (Result Http.Error ())

encodeForm : Form -> Encode.Value
encodeForm form =
    Encode.object
        [ ( "storyText", Encode.string form.storyText )
        , ( "author", Encode.string form.author )
        , ( "title", Encode.string form.title )
        , ( "subtitle", Encode.string form.subtitle )
        , ( "url", Encode.string form.url )
        ]


submitStoryCmd :Model -> Cmd Msg
submitStoryCmd model =
    Http.post
        { url = "http://localhost:5000/api/submit-story"
        , body = Http.jsonBody (encodeForm model.form)
        , expect = Http.expectWhatever SubmissionComplete
        }


init: () -> (Model, Cmd msg)
init flags=
  ( {form =
        { storyText = ""
        , author = ""
        , title = ""
        , subtitle = ""
        , url = ""
        }
         }
    , Cmd.none
    )
update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    case msg of
        ChangeStoryText newStory ->
            let
                oldForm =
                    model.form

                newForm =
                    oldForm |> setFormStoryText newStory
            in
            ({ model | form = newForm }, Cmd.none)


        ChangeAuthor newAuthor ->
            let
                oldForm =
                    model.form

                newForm =
                    oldForm |> setFormAuthor newAuthor
            in
             ({ model | form = newForm }, Cmd.none)

        ChangeTitle newTitle ->
            let
                oldForm =
                    model.form

                newForm =
                    oldForm |> setFormTitle newTitle
            in
            ( { model | form = newForm },Cmd.none)

        ChangeSubtitle newSubtitle ->
            let
                oldForm =
                    model.form

                newForm =
                    oldForm |> setFormSubtitle newSubtitle
            in
            ( { model | form = newForm }, Cmd.none )

        ChangeUrl newUrl ->
            let
                oldForm =
                    model.form

                newForm =
                    oldForm |> setFormUrl newUrl
            in
            ( { model | form = newForm },Cmd.none)

        Submit ->
            ( model, submitStoryCmd model)
        SubmissionComplete result ->
            case result of
                Ok res->
                    (model, Cmd.none)
                Err err->
                    (model, Cmd.none)

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none


view : Model-> Browser.Document Msg
view model =
    {title = "Submit a Story"
    , body = [Element.layout [] (viewForm model.form)]
           }


viewForm form =
    Element.column [ Region.mainContent, Element.width (Element.px 400), Element.centerX ]
        [ Input.spellChecked []
            { label = Input.labelAbove [] (Element.text "Title")
            , onChange = \new -> ChangeTitle new
            , placeholder = Just (Input.placeholder [] (Element.text "Title"))
            , text = form.title
            }
        , Input.spellChecked []
            { label = Input.labelAbove [] (Element.text "Subtitle")
            , onChange = \new -> ChangeSubtitle new
            , placeholder = Just (Input.placeholder [] (Element.text "Subtitle"))
            , text = form.subtitle
            }
        , Input.text []
            { label = Input.labelAbove [] (Element.text "Author")
            , onChange = \new -> ChangeAuthor new
            , placeholder = Just (Input.placeholder [] (Element.text "Author display name goes here"))
            , text = form.author
            }
        , Input.text []
            { label = Input.labelAbove [] (Element.text "url")
            , onChange = \new -> ChangeUrl new
            , placeholder = Just (Input.placeholder [] (Element.text "url"))
            , text = form.url
            }
        , Input.multiline [ Element.height (Element.px 400) ]
            { label = Input.labelAbove [ Element.width Element.fill ] (Element.text "Story")
            , onChange = \new -> ChangeStoryText new
            , placeholder = Just (Input.placeholder [] (Element.text "Story Text goes Here"))
            , text = form.storyText
            , spellcheck = True
            }
        , Input.button []
            { onPress = Just Submit
            , label = Element.text "Submit Story"
            }
        ]

main =
    Browser.document
        { init = init
        , view = view
        , subscriptions = subscriptions
        , update = update
        }