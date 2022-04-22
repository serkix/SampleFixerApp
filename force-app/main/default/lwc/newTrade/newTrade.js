import { LightningElement } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { NavigationMixin } from 'lightning/navigation';
import { reduceErrors } from 'c/ldsUtils';
import getRate from '@salesforce/apex/FixerService.getRate';

// Import objects and fields
import TRADE_OBJECT from '@salesforce/schema/Trade__c';
import BUY_CURRENCY_FIELD from '@salesforce/schema/Trade__c.BuyCurrency__c';
import BUY_AMOUNT_FIELD from '@salesforce/schema/Trade__c.BuyAmount__c';
import SELL_CURRENCY_FIIELD from '@salesforce/schema/Trade__c.SellCurrency__c';
import SELL_AMOUNT_FIIELD from '@salesforce/schema/Trade__c.SellAmount__c';
import RATE_FIIELD from '@salesforce/schema/Trade__c.Rate__c';
import DATE_BOOKED_FIIELD from '@salesforce/schema/Trade__c.DateBooked__c';

// Import labels
import RecordCreated from '@salesforce/label/c.RecordCreated';

export default class NewTrade extends NavigationMixin(LightningElement) {
    tradeObject = TRADE_OBJECT;
    buyCurrencyField = BUY_CURRENCY_FIELD;
    buyAmountField = BUY_AMOUNT_FIELD;
    sellCurrencyField = SELL_CURRENCY_FIIELD;
    sellAmountField = SELL_AMOUNT_FIIELD;
    rateField = RATE_FIIELD;
    dateBookedField = DATE_BOOKED_FIIELD;
    loading = false;

    _ratedDate = null;
    get ratedDate() {
        return this._ratedDate;
    }
    set ratedDate(newVal) {
        this._ratedDate = newVal;
    }

    _buyCurrency = null;
    get hasBuyCurrency() {
        return ((this._buyCurrency !== null) && (this._buyCurrency !== ""));
    }

    _sellCurrency = null;
    get hasSellCurrency() {
        return ((this._sellCurrency !== null) && (this._sellCurrency !== ""));
    }

    _rate = null;
    get rate() {
        return this._rate;
    }
    set rate(newValue) {
        this._rate = newValue;
    }

    _buyAmount = null;
    get buyAmount() {
        return this._buyAmount;
    }
    set buyAmount(newValue) {
        this._buyAmount = newValue;
    }
    get hasBuyAmount() {
        return ((this._buyAmount !== null) && (this._buyAmount !== ""));
    }

    _sellAmount = null;
    get sellAmount() {
        return this._sellAmount;
    }
    set sellAmount(newValue) {
        this._sellAmount = newValue;
    }
    

    buyCurrencyChangeHandle(evt) {
        this._buyCurrency = evt.target.value;
        if (this.hasBuyCurrency && this.hasSellCurrency) {
            this.getNewRate();
        } else {
            this.clearCalculatedFields();
        }
    }
    sellCurrencyChangeHandle(evt) {
        this._sellCurrency = evt.target.value;
        if (this.hasBuyCurrency && this.hasSellCurrency) {
            this.getNewRate();
        } else {
            this.clearCalculatedFields();
        }
    }
    buyAmountChangeHandle(evt) {
        this.buyAmount = evt.target.value;
        if (this.rate !== null) {
            this.calculateSellAmount();
        }
    }

    async getNewRate() {
        this.loading = true;
        let result;
        try {
            let resultJson = await getRate({buyCurrency: this._buyCurrency, sellCurrency: this._sellCurrency});
            result = JSON.parse(resultJson);
        } catch (e) {
            this.showError(e);
            this.loading = false;
            return;
        }
        this.rate = 1 / result.rates[this._buyCurrency];
        this.ratedDate = this.getDateTimeValue();
        if (this.hasBuyAmount) {
            this.calculateSellAmount();
        }
        this.loading = false;
    }

    getDateTimeValue() {
        return (new Date()).toISOString();
    }

    calculateSellAmount() {
        this.sellAmount = this.rate * this.buyAmount;
    }
    clearCalculatedFields() {
        this.rate = null;
        this.sellAmount = null;
        this._ratedDate = null;
    }

    handleCancel(){
        this.returnBack();
    }

    returnBack() {
        window.history.back();
        return false;
    }

    async handleSubmit(event) {
        this.loading = true;
    }

    async handleSuccess(event) {
        this.loading = false;
        let recordId = event.detail.id;
        let pageRef = {
            type: "standard__recordPage",
            attributes: {
                objectApiName: this.tradeObject,
                recordId: recordId,
                actionName: "view"
            },
            state: {
            }
        };
        let url = await this[NavigationMixin.GenerateUrl](pageRef);
        const createdEvent = new ShowToastEvent({
            title: "Success",
            message: RecordCreated,
            variant: 'success',
            messageData: [{url, label: 'here'}]
        });
        this.dispatchEvent(createdEvent);
        this.returnBack();
    }

    async handleError(event) {
        this.loading = false;
        this.showError(event.detail);
    }

    showError(error) {
        const createdEvent = new ShowToastEvent({
            title: "Error",
            message: reduceErrors(error).join(', '),
            variant: 'error'
        });
        this.dispatchEvent(createdEvent);
    }
}