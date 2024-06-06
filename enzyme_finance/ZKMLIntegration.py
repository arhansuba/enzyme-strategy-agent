import os
import pprint
from dotenv import find_dotenv, load_dotenv
from giza.agents.action import action
from giza.agents import GizaAgent
from giza.agents.task import task

# .env dosyasından çevresel değişkenleri yükle
load_dotenv(find_dotenv())

# Çevresel değişkenlerden diğer gerekli değerleri al
MODEL_ID = os.environ.get("MODEL_ID")
VERSION_ID = os.environ.get("VERSION_ID")
USER_ADDRESS = os.environ.get("USER_ADDRESS")
SEPOLIA_RPC_URL = os.environ.get("SEPOLIA_RPC_URL")

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
        result = self.predict(agent, X)
        predicted_value = self.get_pred_val(result)
        pprint.pprint(predicted_value)

# ZKML Integration Agent'i başlat
zkml_integration = ZKMLIntegration()
zkml_integration.transmission()
