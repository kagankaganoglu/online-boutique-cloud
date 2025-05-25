from locust import HttpUser, task, between

class WebsiteUser(HttpUser):
    # Wait between 1 and 5 seconds between tasks to simulate user think time
    wait_time = between(1, 5)

    @task(4)
    def load_homepage(self):
        self.client.get("/")

    @task(3)
    def view_cart(self):
        self.client.get("/cart")

    @task(2)
    def checkout(self):
        self.client.get("/cart/checkout")

    @task(1)
    def view_product_detail(self):
        self.client.get("/product/OLJCESPC7Z")
