import pandas as pd
import numpy as np
from faker import Faker
import hashlib
import json
from datetime import datetime, timedelta
import uuid
import os

# --- Configuration ---
NUM_PROVIDERS = 5
NUM_PLANS_PER_PROVIDER = 5
NUM_USERS = 200
NUM_SUBSCRIPTIONS = 100

# Map currencies to locales for realistic geographic data
CURRENCY_LOCALE_MAP = {
    'USD': 'en_US',
    'EUR': 'de_DE',
    'GBP': 'en_GB',
    'MXN': 'es_MX',
    'SAR': 'ar_SA'
}
CURRENCIES = list(CURRENCY_LOCALE_MAP.keys())


def generate_data():
    """
    Generates enhanced, event-driven sample data for providers, plans, users, and subscription events.
    """
    # --- Providers ---
    fake_provider = Faker()
    providers = pd.DataFrame({
        'provider_id': range(1, NUM_PROVIDERS + 1),
        'provider_name': [fake_provider.company() for _ in range(NUM_PROVIDERS)],
        'api_key': [hashlib.sha256(fake_provider.password().encode()).hexdigest() for _ in range(NUM_PROVIDERS)],
        'created_at': [fake_provider.date_time_this_decade() for _ in range(NUM_PROVIDERS)]
    })

    # --- Plans ---
    fake_plan = Faker()
    plans_data = []
    for provider_id in providers['provider_id']:
        for _ in range(NUM_PLANS_PER_PROVIDER):
            billing_frequency = np.random.choice(
                ['monthly', 'quarterly', 'annual'])
            if billing_frequency == 'monthly':
                price = round(np.random.uniform(20, 100), 2)
            elif billing_frequency == 'quarterly':
                price = round(np.random.uniform(50, 250), 2)
            else:
                price = round(np.random.uniform(200, 1000), 2)

            plans_data.append({
                'plan_id': str(uuid.uuid4()),
                'provider_id': provider_id,
                'plan_name': fake_plan.bs().title(),
                'price': price,
                'currency': np.random.choice(CURRENCIES),
                'billing_frequency': billing_frequency,
                'features': json.dumps(fake_plan.pydict(nb_elements=3, value_types=['str', 'int'])),
                'created_at': fake_plan.date_time_this_decade()
            })
    plans = pd.DataFrame(plans_data)

    # --- Users (with Geographic Data) ---
    users_data = []
    for i in range(NUM_USERS):
        # Cycle through locales to ensure geographic diversity
        locale = CURRENCY_LOCALE_MAP[CURRENCIES[i % len(CURRENCIES)]]
        fake_user = Faker(locale)
        users_data.append({
            'user_id': str(uuid.uuid4()),
            'full_name': fake_user.name(),
            'email': fake_user.email(),
            'phone_number': fake_user.phone_number(),
            'city': fake_user.city(),
            'country': fake_user.country(),
            'created_at': fake_user.date_time_this_decade()
        })
    users = pd.DataFrame(users_data)

    # --- Subscription Events (Event-Driven Model) ---
    fake_event = Faker()
    events_data = []
    for _ in range(NUM_SUBSCRIPTIONS):
        subscription_id = str(uuid.uuid4())
        plan = plans.sample(1).iloc[0]
        user = users.sample(1).iloc[0]

        # Subscription starts between 2 years ago and 2 months ago
        start_date = fake_event.date_time_between(
            start_date='-2y', end_date='-2m')

        # Add creation event
        events_data.append({
            'event_id': str(uuid.uuid4()),
            'subscription_id': subscription_id,
            'plan_id': plan['plan_id'],
            'user_id': user['user_id'],
            'event_type': 'subscription_created',
            'event_timestamp': start_date,
            'amount': plan['price'],  # First payment is part of creation
            'currency': plan['currency']
        })

        # Simulate renewals
        current_date = start_date
        is_active = True
        while is_active and current_date < datetime.now():
            if plan['billing_frequency'] == 'monthly':
                current_date += timedelta(days=30)
            elif plan['billing_frequency'] == 'quarterly':
                current_date += timedelta(days=90)
            else:
                current_date += timedelta(days=365)

            if current_date > datetime.now():
                break

            # 10% chance of a failed renewal
            if np.random.rand() < 0.1:
                events_data.append({
                    'event_id': str(uuid.uuid4()),
                    'subscription_id': subscription_id,
                    'plan_id': plan['plan_id'],
                    'user_id': user['user_id'],
                    'event_type': 'renewal_failed',
                    'event_timestamp': current_date,
                    'amount': 0,  # No revenue for failed events
                    'currency': plan['currency']
                })
                # 50% chance a failed payment leads to cancellation
                if np.random.rand() < 0.5:
                    is_active = False
                    events_data.append({
                        'event_id': str(uuid.uuid4()),
                        'subscription_id': subscription_id,
                        'plan_id': plan['plan_id'],
                        'user_id': user['user_id'],
                        'event_type': 'subscription_cancelled',
                        # Cancellation processed a week later
                        'event_timestamp': current_date + timedelta(days=7),
                        'amount': 0,
                        'currency': plan['currency']
                    })
            else:
                events_data.append({
                    'event_id': str(uuid.uuid4()),
                    'subscription_id': subscription_id,
                    'plan_id': plan['plan_id'],
                    'user_id': user['user_id'],
                    'event_type': 'renewal_successful',
                    'event_timestamp': current_date,
                    'amount': plan['price'],
                    'currency': plan['currency']
                })

    subscription_events = pd.DataFrame(events_data)

    return providers, plans, users, subscription_events


def main():
    """
    Generates data and saves it to CSV files in the seeds directory.
    """
    providers, plans, users, subscription_events = generate_data()

    # Get the directory where the script is located, which is the seeds directory
    seeds_dir = os.path.dirname(os.path.realpath(__file__))

    # Save to CSV in the dbt seeds directory
    providers.to_csv(os.path.join(seeds_dir, 'providers.csv'), index=False)
    plans.to_csv(os.path.join(seeds_dir, 'plans.csv'), index=False)
    users.to_csv(os.path.join(seeds_dir, 'users.csv'), index=False)
    subscription_events.to_csv(os.path.join(
        seeds_dir, 'subscription_events.csv'), index=False)

    # Remove the old stateful subscriptions file if it exists
    old_subscriptions_file = os.path.join(seeds_dir, 'subscriptions.csv')
    if os.path.exists(old_subscriptions_file):
        os.remove(old_subscriptions_file)
        print(f"Removed obsolete file: {old_subscriptions_file}")

    print(f"Generated and saved event-driven data to {seeds_dir}")


if __name__ == "__main__":
    main()
