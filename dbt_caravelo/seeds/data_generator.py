import pandas as pd
import numpy as np
from faker import Faker
import hashlib
import json
from datetime import datetime, timedelta

fake = Faker()


def generate_data(num_providers=5, num_plans_per_provider=5, num_users=200, num_subscriptions=500):
    """
    Generates enhanced sample data for providers, plans, users, and subscriptions.
    """
    # Providers
    providers = pd.DataFrame({
        'provider_id': range(1, num_providers + 1),
        'provider_name': [fake.company() for _ in range(num_providers)],
        'api_key': [hashlib.sha256(fake.password().encode()).hexdigest() for _ in range(num_providers)],
        'created_at': [fake.date_time_this_decade() for _ in range(num_providers)]
    })

    # Plans
    plans_data = []
    for provider_id in providers['provider_id']:
        for _ in range(num_plans_per_provider):
            billing_frequency = np.random.choice(
                ['monthly', 'quarterly', 'annual'])
            if billing_frequency == 'monthly':
                price = round(np.random.uniform(20, 100), 2)
            elif billing_frequency == 'quarterly':
                price = round(np.random.uniform(50, 250), 2)
            else:
                price = round(np.random.uniform(200, 1000), 2)

            plans_data.append({
                'plan_id': fake.uuid4(),
                'provider_id': provider_id,
                'plan_name': fake.bs().title(),
                'price': price,
                'currency': np.random.choice(['USD', 'EUR', 'GBP']),
                'billing_frequency': billing_frequency,
                'features': json.dumps(fake.pydict(nb_elements=3, value_types=['str', 'int'])),
                'created_at': fake.date_time_this_decade()
            })
    plans = pd.DataFrame(plans_data)

    # Users (with PII)
    users_data = []
    for _ in range(num_users):
        users_data.append({
            'user_id': fake.uuid4(),
            'full_name': fake.name(),
            'email': fake.email(),
            'phone_number': fake.phone_number(),
            'address': fake.address().replace('\n', ', '),
            'created_at': fake.date_time_this_decade()
        })
    users = pd.DataFrame(users_data)

    # Subscriptions
    subscriptions_data = []
    for _ in range(num_subscriptions):
        plan = plans.sample(1).iloc[0]
        user = users.sample(1).iloc[0]
        start_date = fake.date_time_between(start_date='-2y', end_date='now')

        if plan['billing_frequency'] == 'monthly':
            end_date = start_date + \
                timedelta(days=30 * np.random.randint(1, 12))
        elif plan['billing_frequency'] == 'quarterly':
            end_date = start_date + \
                timedelta(days=90 * np.random.randint(1, 4))
        else:
            end_date = start_date + \
                timedelta(days=365 * np.random.randint(1, 2))

        subscriptions_data.append({
            'subscription_id': fake.uuid4(),
            'plan_id': plan['plan_id'],
            'user_id': user['user_id'],
            'provider_id': plan['provider_id'],
            'start_date': start_date,
            # Some subscriptions are ongoing
            'end_date': end_date if np.random.rand() > 0.2 else None,
            'status': np.random.choice(['active', 'cancelled', 'past_due'], p=[0.7, 0.2, 0.1]),
            'created_at': start_date
        })
    subscriptions = pd.DataFrame(subscriptions_data)

    return providers, plans, users, subscriptions


def main():
    """
    Generates data and saves it to CSV files in the seeds directory.
    """
    providers, plans, users, subscriptions = generate_data()

    # Save to CSV in the dbt seeds directory
    seeds_dir = 'seeds'
    providers.to_csv(f'{seeds_dir}/providers.csv', index=False)
    plans.to_csv(f'{seeds_dir}/plans.csv', index=False)
    users.to_csv(f'{seeds_dir}/users.csv', index=False)
    subscriptions.to_csv(f'{seeds_dir}/subscriptions.csv', index=False)

    print(f"Generated and saved data to {seeds_dir}")


if __name__ == "__main__":
    main()
