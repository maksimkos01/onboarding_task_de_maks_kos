from pydantic import BaseModel, Field
from typing import List, Optional

# US payload models
class USAddress(BaseModel):
    country_code: str
    city: str
    address: str

class USContact(BaseModel):
    phone_number: str

class USRegisteredCustomer(BaseModel):
    registered_customer_id: str
    first_name: str
    last_name: str
    gender: str
    registered_since: str
    address: USAddress
    contact: USContact
    referred_by: Optional[str] = None

class USModelPurchased(BaseModel):
    line_num: int
    model: str
    model_price: float

class USCardInformation(BaseModel):
    card_number: str
    card_expires: str

class USTotal(BaseModel):
    payment: float
    currency: str

class USPayment(BaseModel):
    card_information: USCardInformation
    total: USTotal

class USSalesTransaction(BaseModel):
    transaction_id: str
    transaction_time: str
    store: str
    registered_customer: Optional[USRegisteredCustomer] = None
    employee: str
    models_purchased: List[USModelPurchased]
    payment: USPayment

# Brazil payload models
class BRLocalizacao(BaseModel):
    ClienteID: int
    ClienteNome: str
    Localizacao: str

class BRCartao(BaseModel):
    Numero: str
    DataDeValidade: str

class BRCabecalho(BaseModel):
    TransacaoID: int
    Moeda: str
    TransacaoTempo: str
    LojaID: str
    Cliente: Optional[BRLocalizacao] = None
    Cartao: BRCartao

class BRModelo(BaseModel):
    ModeloID: str
    Preco: float

class BRSalesElement(BaseModel):
    Cabecalho: BRCabecalho
    Modelo: BRModelo

# The Brazilian payload
class BRSalesMessage(BaseModel):
    root: List[BRSalesElement]
