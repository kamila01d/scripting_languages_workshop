from typing import Any, Text, Dict, List
from rasa_sdk import Action, Tracker
from rasa_sdk.executor import CollectingDispatcher
import json
import os

current_directory = os.getcwd()

hours = 'opening_hours.json'
menu = 'menu.json'

class ActionOrder(Action):
    def name(self) -> Text:
        return "action_order"

    def run(
        self, dispatcher: CollectingDispatcher, tracker: Tracker, domain: Dict[Text, Any]
    ) -> List[Dict[Text, Any]]:
        meal = tracker.latest_message['entities'][0]['value'] if tracker.latest_message['entities'] else None
        json_file_path = os.path.join(current_directory, menu)
        print(meal)
        if meal == None:
            dispatcher.utter_message(text=f"Sorry, We don't have that in our offer :(")
        else:
            with open(json_file_path, 'r') as file:
                data = json.load(file)

            is_in_data = any((str(item["name"]).lower() == meal.lower() for item in data.get("items", [])))

            if is_in_data:
                dispatcher.utter_message(text=f"Great choice! You've selected {meal}")
            else:
                dispatcher.utter_message(text=f"Sorry, We don't have that in our offer :(")
        return []

class ActionShowMenu(Action):
    def name(self) -> Text:
        return "action_show_menu"

    def run(
        self, dispatcher: CollectingDispatcher, tracker: Tracker, domain: Dict[Text, Any]
    ) -> List[Dict[Text, Any]]:

        json_file_path = os.path.join(current_directory, menu)
        with open(json_file_path, 'r') as file:
            data = json.load(file)

        items = data.get("items", [])  # Get the list of items, default to an empty list if not present
        txt = ""

        for item in items:
            name = item.get("name", "")
            price = item.get("price", 0)

            txt+=f"{name:20} - [${price:.2f}]\n"


        dispatcher.utter_message(text=f"This is our menu\n {txt}")
        return []

class ActionShowWhenOpen(Action):
    def name(self) -> Text:
        return "action_show_when_open"

    def run(
        self, dispatcher: CollectingDispatcher, tracker: Tracker, domain: Dict[Text, Any]
    ) -> List[Dict[Text, Any]]:

        json_file_path = os.path.join(current_directory, hours)
        with open(json_file_path, 'r') as file:
            data = json.load(file)

        output_string = ''
        for day, schedule in data.get("items", {}).items():
            open_time = schedule.get("open", 0)
            close_time = schedule.get("close", 0)

            if open_time == 0 and close_time == 0:
                status = "closed"
            else:
                status = f"{open_time:2d}-{close_time:02d}"

            output_string += f"{day.ljust(10)} {status}\n"


        dispatcher.utter_message(text=f"{output_string}")
        return []

class ActionTellIfOpen(Action):
    def name(self) -> Text:
        return "action_tell_if_open"

    def run(
        self, dispatcher: CollectingDispatcher, tracker: Tracker, domain: Dict[Text, Any]
    ) -> List[Dict[Text, Any]]:


        day_entity = tracker.latest_message['entities'][0] if tracker.latest_message['entities'] else None
        time_entity = next((e for e in tracker.latest_message['entities'] if e['entity'] == 'time'), None)
        print(tracker.latest_message['entities'])

        day_ = day_entity['value'] if day_entity else None
        time = ''.join(filter(str.isdigit, time_entity['value'])) if time_entity else None
        day = ''.join(filter(str.isalpha, day_))
        print(time)


        json_file_path = os.path.join(current_directory, hours)
        with open(json_file_path, 'r') as file:
            data = json.load(file)


        day_schedule = data.get("items", {}).get(day.capitalize())
        if day.lower() == 'Sunday'.lower():
            dispatcher.utter_message(f"Sorry, The restaurant is closed on {day}.")

        else:
            open_time = day_schedule.get("open", 0)
            close_time = day_schedule.get("close", 0)
            if time:
                if open_time <= int(time) < close_time:
                    dispatcher.utter_message(f"Yes, the restaurant is open on {day} at {time}.")
                else:
                    dispatcher.utter_message(f"No, the restaurant is closed on {day} at {time}.")
            else:
                dispatcher.utter_message(f"The restaurant is open on  {day} at {open_time} - {close_time} .")



        return []
