## WEB & WAS Loadbalancing & Autoscaling Group
Packer 로 nginx 와 tomcat 의 AMI 이미지를 만듭니다. 만든 이미지는 각 각 계층에서 오토스케일링 그룹으로 만들어집니다. 각 오토스케일링 그룹은 계층별 ELB에 연결되며 지속적인 healcheck 로 검사합니다. 인스턴스 그룹은 CPU 임계치 70%에 오토스케일링됩니다. 

---

### Web Instance Group

- 사진

### Application Instance Group

- 사진
