import os
import numpy as np
from giza.agents.action import action
from giza.agents import AgentResult, GizaAgent
from giza.agents.task import task
from ape import project

# Import Enzyme Finance libraries
from EnzymeVaultInterface import EnzymeVaultInterface
from ZKMLIntegration import ZKMLIntegration

# Import custom libraries from the lib folder
from lib.LibAddressManager import LibAddressManager
from lib.LibBeacon import LibBeacon
from lib.LibBudget import LibBudget
from lib.LibCrossChainOracle import LibCrossChainOracle
from lib.LibEnzymeFiat import LibEnzymeFiat
from lib.LibFarming import LibFarming
from lib.LibMarket import LibMarket
from lib.LibMetaData import LibMetaData
from lib.LibPrice import LibPrice
from lib.LibSales import LibSales
from lib.LibState import LibState
from lib.LibZKM import LibZKM
from lib.LibZeroExOracle import LibZeroExOracle

# Get necessary values from environmental variables
MODEL_ID = os.environ.get("MODEL_ID")
VERSION_ID = os.environ.get("VERSION_ID")
TOKEN_A_ADDRESS = os.environ.get("TOKEN_A_ADDRESS")
TOKEN_B_ADDRESS = os.environ.get("TOKEN_B_ADDRESS")
POOL_ADDRESS = os.environ.get("POOL_ADDRESS")
USER_ADDRESS = os.environ.get("USER_ADDRESS")
POOL_FEE = os.environ.get("POOL_FEE")
TOKEN_A_AMOUNT = os.environ.get("TOKEN_A_AMOUNT")
TOKEN_B_AMOUNT = os.environ.get("TOKEN_B_AMOUNT")
SEPOLIA_RPC_URL = os.environ.get("SEPOLIA_RPC_URL")

# Initialize ape project
project.init()

# Initialize Enzyme Finance libraries
address_manager = LibAddressManager()
beacon = LibBeacon()
budget = LibBudget()
cross_chain_oracle = LibCrossChainOracle()
enzyme_fiat = LibEnzymeFiat()
farming = LibFarming()
market = LibMarket()
meta_data = LibMetaData()
price = LibPrice()
sales = LibSales()
state = LibState()
zkm = LibZKM()
zero_ex_oracle = LibZeroExOracle()

# Initialize EnzymeVaultInterface and ZKMLIntegration
vault_interface = EnzymeVaultInterface()
zkml_integration = ZKMLIntegration()

# Define tasks
@task
def process_data(realized_vol, dec_price_change):
    pct_change_sq = (100 * dec_price_change) ** 2
    X = np.array([[realized_vol, pct_change_sq]])
    return X

@task
def get_data():
    realized_vol = 4.20
    dec_price_change = 0.1
    return realized_vol, dec_price_change

@task
def create_agent(
    model_id: int, version_id: int, chain: str, contracts: dict, account: str
):
    agent = GizaAgent(
        contracts=contracts,
        id=model_id,
        version_id=version_id,
        chain=chain,
        account=account,
    )
    return agent

@task
def predict(agent: GizaAgent, X: np.ndarray):
    prediction = agent.predict(input_feed={"val": X}, verifiable=True, job_size="XL")
    return prediction

@task
def get_pred_val(prediction: AgentResult):
    return prediction.value[0][0]

@task
def get_tick_range(curr_tick, predicted_value, tokenA_decimals, tokenB_decimals, pool_fee):
    # Your implementation to calculate the tick range goes here
    lower_tick = curr_tick - 100
    upper_tick = curr_tick + 100
    return lower_tick, upper_tick

# Define action
@action
def transmission(
    pred_model_id,
    pred_version_id,
    account="dev",
    chain=f"ethereum:sepolia:{SEPOLIA_RPC_URL}",
):
    contracts = {
        "tokenA": [TOKEN_A_ADDRESS],
        "tokenB": [TOKEN_B_ADDRESS],
        "pool": [POOL_ADDRESS],
    }
    agent = create_agent(
        model_id=pred_model_id,
        version_id=pred_version_id,
        chain=chain,
        contracts=contracts,
        account=account,
    )
    realized_vol, dec_price_change = get_data()
    X = process_data(realized_vol, dec_price_change)
    result = predict(agent, X)
    predicted_value = get_pred_val(result)

    with agent.execute() as contracts:
        _, curr_tick, _, _, _, _, _ = contracts.pool.slot0()
        tokenA_decimals = contracts.tokenA.decimals()
        tokenB_decimals = contracts.tokenB.decimals()
        lower_tick, upper_tick = get_tick_range(
            curr_tick, predicted_value, tokenA_decimals, tokenB_decimals, POOL_FEE
        )
        
        # Example usage of EnzymeVaultInterface
        vault_details = vault_interface.get_vault_details(USER_ADDRESS)
        print(f"Vault Details: {vault_details}")

        # Example usage of ZKMLIntegration
        proof = zkml_integration.generate_proof({"data": X})
        verified = zkml_integration.verify_proof(proof)
        print(f"Proof Verified: {verified}")

        # Assuming you have a function to mint tokens or perform other actions
        # contract_result = contracts.nft_manager.mint(mint_params)
        # Replace the line above with your actual contract interaction code

    # pprint.pprint(contract_result.__dict__)

transmission(MODEL_ID, VERSION_ID)
