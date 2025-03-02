import json
from datetime import datetime
from typing import Any, Dict, List, Text

from rasa_sdk import Action, Tracker
from rasa_sdk.events import SlotSet, UserUtteranceReverted
from rasa_sdk.executor import CollectingDispatcher
from rasa_sdk.types import DomainDict

# def get_menu_item(menu, name) -> Any:
#     next((x for x in menu["items"] if x["name"].lower() == name.lower()), None)

def find_item_by_name(menu, name) -> Any:
    name_lower = name.lower()
    for item in menu["items"]:
        if item["name"].lower() == name_lower:
            return item
    return None


class ActionCheckHours(Action):
    def name(self) -> Text:
        return "action_check_hours"

    async def run(
        self,
        dispatcher: CollectingDispatcher,
        tracker: Tracker,
        domain: DomainDict,
    ) -> List[Dict[Text, Any]]:
        with open("opening_hours.json") as f:
            hours = json.load(f)

        day = tracker.get_slot("day")
        hour = tracker.get_slot("hour")

        if not day and not hour:
            response = self.hours_all_days(hours["items"])
            dispatcher.utter_message(text=response)
            return []

        if day == "today":
            day = datetime.now().strftime("%A")

        if day not in hours["items"].keys():  # day is invalid
            response = self.hours_all_days(hours["items"])
            dispatcher.utter_message(text=response)
            return []

        hours_today = hours["items"][day]

        if hours_today["open"] == 0 and hours_today["close"] == 0:
            response = f"We're closed on {day}s."
        else:
            if hour is None:
                response = f"On {day}s we're open from {hours_today['open']}:00 to {hours_today['close']}:00"
            else:
                if hours_today["open"] <= hour < hours_today["close"]:
                    response = f"Yes, we're open on {day}s at {hour}:00"
                else:
                    response = f"No, we're closed on {day}s at {hour}:00"

        dispatcher.utter_message(text=response)
        return []

    def hours_all_days(self, days):
        response = "Our opening hours are:"

        for day, time in days.items():
            if time["open"] == 0 and time["close"] == 0:
                response += f"\n - {day}: Closed"
            else:
                response += f"\n - {day}: {time['open']}:00 - {time['close']}:00"

        return response


class ActionShowMenu(Action):
    def name(self) -> Text:
        return "action_show_menu"

    async def run(
        self,
        dispatcher: CollectingDispatcher,
        tracker: Tracker,
        domain: DomainDict,
    ) -> List[Dict[Text, Any]]:
        with open("menu.json") as f:
            menu = json.load(f)

        menu_text = "Our menu:\n"
        for item in menu["items"]:
            menu_text += f" - {item['name']}: ${item['price']}\n"

        dispatcher.utter_message(text=menu_text)
        return []


class ActionPlaceOrder(Action):
    def name(self) -> Text:
        return "action_place_order"

    async def run(
        self,
        dispatcher: CollectingDispatcher,
        tracker: Tracker,
        domain: DomainDict,
    ) -> List[Dict[Text, Any]]:
        with open("menu.json") as f:
            menu = json.load(f)

        dish = tracker.get_slot("dish")

        if dish is None:
            dispatcher.utter_message(
                text="Please ask again providing the item you want to order."
            )
            return [UserUtteranceReverted()]

        menu_item = find_item_by_name(menu, dish)

        if menu_item:
            prep_time = menu_item["preparation_time"] * 60
            response = f"I've confirmed your order for {dish}. It will take about {prep_time} minutes to prepare."

            dispatcher.utter_message(text=response)
            return [SlotSet("dish", dish)]
        else:
            response = f"I'm sorry, but {dish} is not on our menu."

            dispatcher.utter_message(text=response)
            return [SlotSet("dish", None), UserUtteranceReverted()]


class ActionChoosePickup(Action):
    def name(self) -> str:
        return "action_choose_pickup"

    async def run(
        self,
        dispatcher: CollectingDispatcher,
        tracker: Tracker,
        domain: dict[str, Any],
    ) -> list[dict[str, Any]]:
        with open("menu.json") as f:
            menu = json.load(f)

        dish = tracker.get_slot("dish")

        if dish is None:
            dispatcher.utter_message(text="You have not placed an order yet.")
            return []

        menu_item = find_item_by_name(menu, dish)

        preparation_time = int(menu_item["preparation_time"] * 60)
        msg = (
            f"Your order will be ready for pickup in about {preparation_time} minutes."
        )
        dispatcher.utter_message(text=msg)
        return []


class ActionChooseDelivery(Action):
    def name(self) -> str:
        return "action_choose_delivery"

    async def run(
        self,
        dispatcher: CollectingDispatcher,
        tracker: Tracker,
        domain: dict[str, Any],
    ) -> list[dict[str, Any]]:
        with open("menu.json") as f:
            menu = json.load(f)

        dish = tracker.get_slot("dish")
        address = tracker.get_slot("address")

        if dish is None:
            dispatcher.utter_message(text="You have not placed an order yet.")
            return []

        menu_item = find_item_by_name(menu, dish)

        delivery_time = int(menu_item["preparation_time"] * 60) + 25
        msg = f"Your order will be delivered to your location in about {delivery_time} minutes.\n - Location: {address}."
        dispatcher.utter_message(text=msg)
        return []
