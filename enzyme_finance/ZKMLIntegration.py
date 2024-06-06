import os
import pprint
import numpy as np
from giza.agents.action import action
from giza.agents import GizaAgent
from giza.agents.task import task



# Get necessary values from environmental variables
MODEL_ID = os.environ.get("MODEL_ID")
VERSION_ID = os.environ.get("VERSION_ID")
USER_ADDRESS = os.environ.get("USER_ADDRESS")
SEPOLIA_RPC_URL = os.environ.get("SEPOLIA_RPC_URL")

# Example function to generate sample data (replace with your actual data generation logic)
def generate_data():
    realized_vol = np.random.uniform(0, 10)
    dec_price_change = np.random.uniform(-0.1, 0.1)
    return realized_vol, dec_price_change

# ZKML Integration Agent
class ZKMLIntegration:
    def __init__(self):
        self.model_id = MODEL_ID
        self.version_id = VERSION_ID
        self.user_address = USER_ADDRESS
        self.chain = f"ethereum:sepolia:{SEPOLIA_RPC_URL}"

    @task
    def create_agent(self):
        agent = GizaAgent(
            id=self.model_id,
            version_id=self.version_id,
            chain=self.chain,
            account=self.user_address,
        )
        return agent

    @task
    def predict(self, agent: GizaAgent, X):
        prediction = agent.predict(input_feed={"val": X}, verifiable=True, job_size="XL")
        return prediction

    @task
    def get_pred_val(self, prediction):
        return prediction.value[0][0]

    @action
    def transmission(self):
        agent = self.create_agent()
        realized_vol, dec_price_change = generate_data()  # Generate sample data
        X = np.array([[realized_vol, dec_price_change]])  # Create input data
        result = self.predict(agent, X)
        predicted_value = self.get_pred_val(result)
        pprint.pprint(predicted_value)

# ZKML Integration Agent'i başlat
zkml_integration = ZKMLIntegration()
zkml_integration.transmission()
