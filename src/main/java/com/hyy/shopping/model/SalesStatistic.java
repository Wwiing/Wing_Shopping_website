package com.hyy.shopping.model;

public class SalesStatistic {
    private Product product;
    private int totalQuantity;

    public SalesStatistic(Product product, int totalQuantity) {
        this.product = product;
        this.totalQuantity = totalQuantity;
    }

    public Product getProduct() {
        return product;
    }

    public void setProduct(Product product) {
        this.product = product;
    }

    public int getTotalQuantity() {
        return totalQuantity;
    }

    public void setTotalQuantity(int totalQuantity) {
        this.totalQuantity = totalQuantity;
    }
}

