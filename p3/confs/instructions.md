## Instructions:

### Argo CD Installation:
1. Run the following command to apply the namespaces configuration:
    ```
    kubectl apply -f ./namespaces.yaml
    ```

2. Run the following command to install Argo CD in the `argocd` namespace:
    ```
    kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
    ```

3. Run the following command to forward the Argo CD server port:
    ```
    kubectl port-forward svc/argocd-server -n argocd 8080:443
    ```

4. Retrieve the initial admin password using the following command:
    ```
    kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d
    ```

5. Access the Argo CD UI by visiting `https://localhost:8080` in your browser and log in with the username `admin` and the password retrieved in step 4.
